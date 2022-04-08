#!/usr/bin/env node

'use strict';

process.on('unhandledRejection', x => { throw x; });

const childproc = require('child_process');
const fsp = require('fs')
	.promises;

const get = async url => {
	console.log(`fetch ${url}`);
	const args = ['-sL', url];
	if(process.env.NC_WEBLATE_TOKEN)
		args.unshift('-H', `Authorization: Token ${process.env.NC_WEBLATE_TOKEN}`);
	const proc = childproc.spawn('curl', args, {
		stdio: 'ignore pipe inherit'.split(' ')
	});
	return await new Promise((res, rej) => {
		proc.stdout.on('error', rej);
		let buffs = [];
		proc.stdout.on('data', x => buffs.push(x));
		proc.stdout.on('close', () => res(Buffer.concat(buffs).toString()));
	});
};

async function* getpaged(url) {
	while(url) {
		const data = JSON.parse(await get(url));
		for(let i of (data.results || []))
			yield i;
		url = data.next;
	}
}

const ifmatch = (str, rx, func) => {
	const m = str.match(rx);
	if(m) return func(m);
};

const getlang = async lang => {
	const raw = await get(`https://hosted.weblate.org/api/translations/minetest/nodecore/${lang}/file/`);
	await fsp.writeFile(`${lang}.txt`, raw);
	const db = {};
	let id;
	for(let line of raw.split('\n')) {
		ifmatch(line, /^\s*msgid\s+"(.*)"\s*$/, m => id = m[1]);
		if(!/\S/.test(id))
			continue;
		let str;
		if(!ifmatch(line, /^\s*(?:msgstr\s+)?"(.*)"\s*$/, m => str = m[1]))
			continue;
		if(!/\S/.test(str))
			continue;
		db[id] = (db[id] || '') + str.replace(/\\"/g, '"');
	}
	return db;
};

const main = async () => {
	const db = {};

	for await (let row of getpaged(
		'https://hosted.weblate.org/api/components/minetest/nodecore/translations/?format=json'))
	if(row.language && row.language.code)
		db[row.language.code] = getlang(row.language.code);
	for(let [k, v] of Object.entries(db))
		db[k] = await v;

	// Clean out strings removed from English
	const en = db.en;
	for(let v of Object.values(db))
		if(v !== en)
			for(let k of Object.keys(v))
				if(!en[k])
					delete v[k];

	// Share strings between related languages
	const langpairs = Object.keys(db)
		.map(k => ({ spec: k, gen: k.replace(/_.*/, '') }))
		.filter(x => x.gen !== x.spec);
	for(let { gen, spec } of langpairs)
		db[gen] = Object.assign({}, db[spec], db[gen] || {});
	for(let { gen, spec } of langpairs)
		db[spec] = Object.assign({}, db[gen], db[spec]);

	for(let [code, data] of Object.entries(db))
		if(code !== 'en') {
			const body = Object.keys(data)
				.sort()
				.map(k => [k, data[k]])
				.filter(([k, v]) => k !== v)
				.map(([k, v]) => `${k}=${v}\n`)
				.sort()
				.join('');
			if(body)
				await fsp.writeFile(`../nc_api.${code}.tr`,
					`# textdomain: nc_api\n${body}`);
		}
};

main();
