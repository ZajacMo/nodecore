'use strict';

const tmp = require('tmp');
const childproc = require('child_process');

const tmps = [];

function tmpng() {
	const ref = tmp.fileSync({
		postfix: '.png'
	});
	tmps.push(ref);
	return ref.name;
}
const mysys = (...args) => {
	console.log(`# ${args.join(' ')}`);
	const cmd = args.shift();
	const proc = childproc.spawn(cmd, args, {
		stdio: 'inherit'
	});
	return new Promise((r, j) => {
		proc.on('error', j);
		proc.on('exit', (c, s) => s ? j(`signal ${s}`) : c ? j(`code ${c}`) : r())
	});
};

async function offset(inf, outf, w, h, dx, dy) {
	const tmp1 = tmpng();
	await mysys('convert', '+append', inf, inf, tmp1);
	const tmp2 = tmpng();
	await mysys('convert', '-append', tmp1, tmp1, tmp2);
	await mysys('convert', tmp2, '+repage', '-crop', `${w}x${h}+${dx}+${dy}`, outf);
}

async function finish(name, frames) {
	frames.push(frames[0]);
	frames.push(frames[0]);
	await mysys('convert', ...frames, '+repage', '-flatten', name);
}

async function main() {
	try {
		const xf = [
			[0, 0],
			[2, 1],
			[1, 3],
			[3, 8]
		];
		const blur = []
		for (let i = 1; i <= 4; i++) {
			const tmp1 = tmpng();
			await mysys('convert', `mask${i}.png`,
				'-virtual-pixel', 'tile',
				'-interpolate', 'catrom',
				'-attenuate', '5', '+noise', 'gaussian',
				'-blur', '0x0.5',
				'-colorspace', 'gray', '-colorspace', 'rgb',
				tmp1);
			const blurred = tmpng();
			await offset(tmp1, blurred, 16, 16, ...(xf[i - 1]));
			blur[i] = blurred;
		}
		const stat = [];
		const anim = [];
		for (let i = 0; i < 32; i++) {
			const r = Math.sin(Math.PI / 2 * (i % 8) / 8);
			const m = Math.floor(i / 8) + 1;
			const n = (m % 4) + 1;
			const outf = tmpng();
			await mysys('composite', '-dissolve', r * 100,
				blur[n], blur[m], outf);
			stat.push('-append', outf);
			const rotf = tmpng();
			await offset(outf, rotf, 16, 16, 0, 15 - (i % 16));
			anim.push('-append', rotf);

		}
		await finish('out-static.png', stat);
		await finish('out-anim.png', anim);
	} finally {
		tmps.forEach(x => x.removeCallback());
	}
}
main();