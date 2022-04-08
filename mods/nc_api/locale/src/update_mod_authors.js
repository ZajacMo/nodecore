'use strict';

const { get, getpaged } = require('./update_lib_fetch');
const fsp = require('fs')
	.promises;

const authorfile = 'authors.json';
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
		let user = authordb.user[row.author];
		if(!user)
			authordb.user[row.author] = user = {
				raw: JSON.parse(await get(row.author)),
				first: row.timestamp,
				last: row.timestamp
			};
		if(row.timestamp < user.first)
			user.first = row.timestamp;
		if(row.timestamp > user.last)
			user.last = row.timestamp;
	}
})());

const done = async () => {
	await Promise.all(authortasks);
	await fsp.writeFile(authorfile, JSON.stringify(await getauthordb, null, '\t'));
};

module.exports = { onlang, done };
