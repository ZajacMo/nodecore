'use strict';

process.on('unhandledRejection', x => { throw x; });

const { getpaged } = require('./update_lib_fetch');

const modules = ['authors', 'strings']
	.map(x => require(`./update_mod_${x}`));

const main = async () => {
	for await (let row of getpaged(
		'/api/components/minetest/nodecore/translations/?format=json'))
	if(row.language && row.language.code)
		for(let mod of modules)
			mod.onlang(row.language.code);
	await Promise.all(modules.map(async x => await x.done()));
};

main();
