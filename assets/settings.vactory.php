<?php

// @codingStandardsIgnoreFile

/**
 * Suppress ITOK.
 */
$config['image.settings']['suppress_itok_output'] = TRUE;
$config['image.settings']['allow_insecure_derivatives'] = TRUE;

/**
 * Private file path.
 */
$settings['file_private_path'] = 'sites/default/private';

/**
 * Public file path.
 */
$settings['file_public_path'] = 'sites/default/files';

/**
 * File system temporary.
 */
$config['system.file']['path']['temporary'] = '/tmp';

/**
 * Path to translation files.
 */
$config['locale.settings']['translation']['path'] = 'sites/default/files/translations';

/**
 * Default Salt.
 */
$settings['hash_salt'] = 'P6qFdKCJbZGT98t7PlxYlEOLLqKanlyT';

/**
 * Disable CSS and JS aggregation.
 */
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;

/**
 * CONFIG SYNC.
 */
$settings['config_sync_directory'] = 'profiles/contrib/vactory/config/sync';

/**
 * Redirect all site mails to one mail address in local environment.
 * Into your settings.local.php file override $settings['vactory_mail_redirect']
 * by specifying the address to which all site mails should be delivered.
 *
 * Example:
 * $settings['vactory_mail_redirect'] = 'toto@void.fr';
 *
 * From now on, all site mails will be redirected to toto@void.fr address.
 */
# $settings['vactory_mail_redirect'] = 'toto@void.fr';

/**
 * @todo: Enter your project empty database connection infos (username, password, port...) before executing profile installation.
 */
$databases['default']['default'] = array (
  'database' => 'vactory_db',
  'username' => 'root',
  'password' => 'root',
  'prefix' => '',
  'host' => '127.0.0.1',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);
