import { RemoteDownloader } from '../../downloaders/remote.js';
import { DirectoryDownloader } from '../../downloaders/directory.js';
import { createRequire } from 'node:module';
import { dirname } from 'node:path';
import { createIconSetsPackageImporter } from '../../importers/full/json.js';
import type { RemoteDownloaderOptions } from '../../types/downloaders/remote.js';
import type { ImportedData } from '../../types/importers/common.js';

/**
 * Importer for all icon sets from `@iconify/json` package
 */

// Source options, select one you prefer

// 优先使用本地包
let localDir: string | undefined;
try {
	const req = createRequire(import.meta.url);
	const filename = req.resolve('@iconify/json/package.json');
	localDir = filename ? dirname(filename) : undefined;
} catch (err) {
	// 本地包不存在
}

// Import from GitHub. Requires setting GitHub API token in environment variable `GITHUB_TOKEN`
const github: RemoteDownloaderOptions = {
	downloadType: 'github',
	user: 'iconify',
	repo: 'icon-sets',
	branch: 'master',
	token: process.env['GITHUB_TOKEN'] || '',
};

// Import from GitHub using git client. Does not require any additonal configuration
const git: RemoteDownloaderOptions = {
	downloadType: 'git',
	remote: 'http://127.0.0.1/icon-sets.git', // 禁用 https，填入本地/内网占位符
	branch: 'master',
};

export const fullPackageImporter = localDir
	? createIconSetsPackageImporter(new DirectoryDownloader<ImportedData>(localDir), {
			filter: (prefix, info) => true,
	  })
	: createIconSetsPackageImporter(
			new RemoteDownloader<ImportedData>(
				{
					downloadType: 'npm',
					package: '@iconify/json',
				},
				true
			),
			{
				filter: (prefix, info) => true,
			}
	  );
