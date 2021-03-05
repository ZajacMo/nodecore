'use strict';

const fs = require('fs');

const raw = JSON.parse(fs.readFileSync(0));

const stacks = {};
const items = {};

const base = 2;
Object.values(raw).forEach(v => {
	const m = v.match(/ (\d+)$/);
	const qty = m && Number(m[1]) || 1;
	v = v.replace(/ (\d+)$/, '');
	stacks[v] = (stacks[v] || 0) + 1;

	// Special case: collapse "boosted" infused tools into
	// regular ones.
	v = v.replace(/_boost$/, '');

	items[v] = (items[v] || 0) + qty;
});

const final = {};
Object.keys(items).forEach(k => final[k] = {
	prob: stacks[k],
	qty: Math.floor(items[k] / stacks[k])
});

console.log('return {');
Object.keys(items)
	.sort((a, b) => stacks[b] - stacks[a])
	.slice(0, 100)
	.forEach(k => console.log(`\t["${k}"] = {prob = ${stacks[k]}, qty = ${
		Math.round(items[k] / stacks[k])}},`));
console.log('}');