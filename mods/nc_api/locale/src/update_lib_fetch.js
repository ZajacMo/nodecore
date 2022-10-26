'use strict';

process.on('unhandledRejection', x => { throw x; });

const childproc = require('child_process');

const queue = (() => {
	const limit = 4;
	const queue = [];
	let running = 0;

	const start = job => (async () => {
		try {
			try {
				job.res(await job.act());
			} catch (e) {
				job.rej(e);
			}
		} finally {
			running--;
			checkstart();
		}
	})();

	const checkstart = () => {
		while(queue.length && (running < limit)) {
			const job = queue.shift();
			running++;
			start(job);
		}
	};

	return act => {
		let res, rej;
		const prom = new Promise((r, j) => {
			res = r;
			rej = j;
		});
		act = {
			act,
			res,
			rej,
			prom
		};
		queue.push(act);
		checkstart();
		return act.prom;
	};
})();

const get = async url => await queue(async () => {
	console.log(`fetch ${url}`);
	if(!url.startsWith('http'))
		url = `https://hosted.weblate.org${url}`;
	const args = ['-fsL', url];
	if(process.env.NC_WEBLATE_PROXY)
		args.unshift('-x', process.env.NC_WEBLATE_PROXY);
	if(process.env.NC_WEBLATE_TOKEN)
		args.unshift('-H', `Authorization: Token ${process.env.NC_WEBLATE_TOKEN}`);
	const proc = childproc.spawn('curl', args, {
		stdio: 'ignore pipe inherit'.split(' ')
	});
	return await new Promise((res, rej) => {
		proc.stdout.on('error', rej);
		let buffs = [];
		proc.stdout.on('data', x => buffs.push(x));
		proc.stdout.on('close', () => res(Buffer.concat(buffs)
			.toString()));
	});
});

async function* getpaged(url) {
	while(url) {
		const data = JSON.parse(await get(url));
		for(let i of (data.results || []))
			yield i;
		url = data.next;
	}
}

module.exports = { get, getpaged };
