'use strict';

const { get } = require('./update_lib_fetch');
const fsp = require('fs')
	.promises;
const db = {};

const codemap = {
	lzh: 'zh',
	zh_Hans: 'zh_CN',
	zh_Hant: 'zh_TW',
};

const ifmatch = (str, rx, func) => {
	const m = str.match(rx);
	if(m) return func(m);
};

const onlang = lang => db[lang] = (async () => {
	const raw = await get(`/api/translations/minetest/nodecore/${lang}/file/`);
	await fsp.writeFile(`raw/${lang}.txt`, raw);
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
})();

const done = async () => {
	for(let [k, v] of Object.entries(db))
		db[k] = await v;

	// Clean out strings removed from English
	const en = db.en;
	for(let v of Object.values(db))
		if(v !== en)
			for(let k of Object.keys(v))
				if(!en[k])
					delete v[k];

	const stats = { en: Object.keys(db.en).length };
	for(let [code, data] of Object.entries(db))
		stats[code] = Object.keys(data).length;
	await fsp.writeFile('../../translated.lua', `return {\n${
		Object.keys(stats).sort().map(k => `\t${codemap[k] || k} = ${stats[k]},\n`).join('')
	}}\n`);

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
			const ents = Object.keys(data)
				.map(k => [k, data[k]])
				.filter(([k, v]) => k !== v)
				.map(([k, v]) => `${k}=${v}\n`)
				.sort();
			const body = ents.join('');
			if(body)
				await fsp.writeFile(`../nc_api.${codemap[code] || code}.tr`,
					`# textdomain: nc_api\n${body}`);
		}
};

module.exports = { onlang, done };
