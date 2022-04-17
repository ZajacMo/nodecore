'use strict';

const { get, getpaged } = require('./update_lib_fetch');
const fsp = require('fs')
	.promises;

const authorfile = 'authors.json';
const licensefile = '../../../../LICENSE';

const overrides = {
	Wuzzy: { email: 'almikes@aol.com' },
	'lesha.programmer': { email: 'lesha.programmer@gmail.com', first: '2021' },
	kuboid: { email: 'community@radtournetz.de', first: '2021' },
	Warr1024: { omit: true }
};

const getauthordb = (async () => {
	try {
		return JSON.parse(await fsp.readFile(authorfile));
	} catch (err) {
		if(err.code === 'ENOENT') return {};
		throw err;
	}
})();

const authortasks = [];
const onlang = lang => authortasks.push((async () => {
	const authordb = await getauthordb;
	authordb.since = authordb.since || {};
	authordb.user = authordb.user || {};

	const params = [
		['format', 'json'],
		['action', '2'],
		['action', '5']
	];
	if(authordb.since[lang])
		params.push(['timestamp_after', authordb.since[lang]]);
	for await (let row of getpaged(
		`/api/translations/minetest/nodecore/${lang}/changes/?` +
		params.map(x => x.map(encodeURIComponent)
			.join('='))
		.join('&')
	)) {
		if(!row.timestamp || !row.author)
			continue;
		if(!authordb.since[lang] || row.timestamp > authordb.since[lang])
			authordb.since[lang] = row.timestamp;
		const year = row.timestamp.substring(0, 4);
		let user = authordb.user[row.author];
		if(!user)
			authordb.user[row.author] = user = {
				raw: JSON.parse(await get(row.author)),
				first: year,
				last: year
			};
		if(year < user.first)
			user.first = year;
		if(year > user.last)
			user.last = year;
	}
})());

const done = async () => {
	await Promise.all(authortasks);
	const authordb = await getauthordb;

	await fsp.writeFile(authorfile, JSON.stringify(authordb, null, '\t'));

	const lines = Object.assign(...Object.values(authordb.user)
		.map(x => Object.assign({}, x, overrides[x.raw.username] || {}))
		.filter(x => !x.omit)
		.map(x => Object.assign({}, x, {
			url: x.email || `https://hosted.weblate.org/user/${x.raw.username}/`
		}))
		.map(x => ({
			[x.url]: `Portions Copyright (C)${x.first}${x.first === x.last
				? '' : `-${x.last}`} ${x.raw.full_name} <${x.url}>`
		})));

	const license = (await fsp.readFile(licensefile))
		.toString()
		.split('\n');
	for(let i = 0; i < license.length; i++) {
		const line = license[i];
		if(/^Portions/.test(line)) {
			const m = line.match(/<([^>]+)>/);
			if(m && lines[m[1]]) {
				license[i] = lines[m[1]];
				delete lines[m[1]];
			}
		}
		if(!/\S/.test(line)) {
			license.splice(i, 0, ...Object.values(lines));
			break;
		}
	}
	await fsp.writeFile(licensefile, license.join('\n'));
};

module.exports = { onlang, done };
