<?php

// phpcs:disable

/**
 * @file
 * Contains \VoidFactory\composer\ScriptHandler.
 */

namespace VoidFactory\composer;

use Composer\Script\Event;
use Composer\Semver\Comparator;
use DrupalFinder\DrupalFinder;
use Symfony\Component\Filesystem\Filesystem;
use Webmozart\PathUtil\Path;

class ScriptHandler {

  public static function createRequiredFiles(Event $event) {
    $fs = new Filesystem();
    $drupalFinder = new DrupalFinder();
    $drupalFinder->locateRoot(getcwd());
    $drupalRoot = $drupalFinder->getDrupalRoot();
//    $dirs = [
//      'modules',
//      'profiles',
//      'themes',
//    ];
//    // Required for unit testing
//    foreach ($dirs as $dir) {
//      if (!$fs->exists($drupalRoot . '/' . $dir)) {
//        $fs->mkdir($drupalRoot . '/' . $dir);
//        $fs->touch($drupalRoot . '/' . $dir . '/.gitkeep');
//      }
//    }
//    // Prepare the settings file for installation
//    if (!$fs->exists($drupalRoot . '/sites/default/settings.php') and $fs->exists($drupalRoot . '/sites/default/default.settings.php')) {
//      $fs->copy($drupalRoot . '/sites/default/default.settings.php', $drupalRoot . '/sites/default/settings.php');
//      require_once $drupalRoot . '/core/includes/bootstrap.inc';
//      require_once $drupalRoot . '/core/includes/install.inc';
//      $settings['config_directories'] = [
//        CONFIG_SYNC_DIRECTORY => (object) [
//          'value'    => Path::makeRelative($drupalFinder->getComposerRoot() . '/config/sync', $drupalRoot),
//          'required' => TRUE,
//        ],
//      ];
//      drupal_rewrite_settings($settings, $drupalRoot . '/sites/default/settings.php');
//      $fs->chmod($drupalRoot . '/sites/default/settings.php', 0666);
//      $event->getIO()
//        ->write("Create a sites/default/settings.php file with chmod 0666");
//    }
//    // Create the files directory with chmod 0777
//    if (!$fs->exists($drupalRoot . '/sites/default/files')) {
//      $oldmask = umask(0);
//      $fs->mkdir($drupalRoot . '/sites/default/files', 0777);
//      umask($oldmask);
//      $event->getIO()
//        ->write("Create a sites/default/files directory with chmod 0777");
//    }
  }

  /**
   * Checks if the installed version of Composer is compatible.
   *
   * Composer 1.0.0 and higher consider a `composer install` without having a
   * lock file present as equal to `composer update`. We do not ship with a lock
   * file to avoid merge conflicts downstream, meaning that if a project is
   * installed with an older version of Composer the scaffolding of Drupal will
   * not be triggered. We check this here instead of in drupal-scaffold to be
   * able to give immediate feedback to the end user, rather than failing the
   * installation after going through the lengthy process of compiling and
   * downloading the Composer dependencies.
   *
   * @see https://github.com/composer/composer/pull/5035
   */
  public static function checkComposerVersion(Event $event) {
    $composer = $event->getComposer();
    $io = $event->getIO();
    $version = $composer::VERSION;

    if (Comparator::notEqualTo($version, '1.7.2')) {
      $io->writeError('<error>Vactory requires Composer version 1.7.2. Please update your Composer before continuing</error>.');
      exit(1);
    }
  }
}
