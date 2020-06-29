<?php

// phpcs:disable

/**
 * @file
 * Contains \VoidFactory\composer\ThemeScriptHandler.
 */

namespace VoidFactory\composer;

use Composer\Script\Event;
use DrupalFinder\DrupalFinder;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Yaml\Yaml;

class ThemeScriptHandler {

  /**
   * Check requirements.
   *
   * @param \Composer\Script\Event $event
   */
  public static function checkRequirement(Event $event) {
    $io = $event->getIO();

    if (`which npm`) {
      $io->write("<info>Success:</info> npm installed. <info>✔</info>");
    }
    else {
      $io->writeError('<error>Error: </error> npm not installed.');
      exit(1);
    }

    if (`which gulp`) {
      $io->write("<info>Success:</info> gulp installed. <info>✔</info>");
    }
    else {
      $io->writeError('<error>Error: </error> gulp not installed.');
      exit(1);
    }
  }

  /**
   * Create a subtheme based on Vactory theme.
   *
   * @param \Composer\Script\Event $event
   *
   * @throws \Exception
   */
  public static function createTheme(Event $event) {
    $io = $event->getIO();
    $fs = new Filesystem();
    $drupalFinder = new DrupalFinder();
    $drupalFinder->locateRoot(getcwd());
    $drupalRoot = $drupalFinder->getDrupalRoot();


    // Questions.
    $theme_name = $io->askAndValidate('Enter your theme name: ', function ($value) use ($io, $fs, $drupalRoot) {
      $theme_path = $drupalRoot . '/themes/' . $value;

      if (preg_match("/^[a-z]{4,}/", $value)) {
        if ($fs->exists($theme_path)) {
          throw new \Exception('Theme name already in use. See ' . $theme_path);
        }

        return $value;
      }
      else {
        throw new \Exception('Theme name not valid. It should contain only [a,z] and at least 4 chars.');
      }
    });

    // Summary Message.
    $io->write(PHP_EOL);
    $io->write('<comment>Theme Name: </comment>' . $theme_name);
    $io->write('<comment>Project Root: </comment>' . $drupalRoot);
    $io->write('<comment>Theme Root: </comment>' . $drupalRoot . '/themes/' . $theme_name);

    if ($io->askConfirmation('<info>Would you like to proceed the theme generation? </info>[<comment>yes</comment>]: ', TRUE)) {
      // Paths.
      $base_theme_path = $drupalRoot . '/themes/vactory';
      $theme_path = $drupalRoot . '/themes/' . $theme_name;

      // Copy folder.
      $flags = \FilesystemIterator::SKIP_DOTS;
      $iterator = new \RecursiveIteratorIterator(new \RecursiveDirectoryIterator($base_theme_path, $flags), \RecursiveIteratorIterator::CHILD_FIRST);
      $filter_iterator = new ExcludeFilesFilterIterator($iterator);
      $fs->mirror($base_theme_path, $theme_path, $filter_iterator);

      // Rename files.
      $fs->rename($theme_path . '/vactory.info.yml', $theme_path . "/{$theme_name}.info.yml");
      $fs->rename($theme_path . '/vactory.libraries.yml', $theme_path . "/{$theme_name}.libraries.yml");
      $fs->rename($theme_path . '/src/scss/vactory.style.scss', $theme_path . "/src/scss/{$theme_name}.style.scss");
      $fs->rename($theme_path . '/config/install/vactory.settings.yml', $theme_path . "/config/install/{$theme_name}.settings.yml");

      // Create .theme file.
      $fs->touch($theme_path . "/{$theme_name}.theme");

      // THEME.info.yml
      $data = Yaml::parseFile($theme_path . "/{$theme_name}.info.yml");
      $data['name'] = $theme_name;
      $data['base theme'] = 'vactory';

      foreach ($data['libraries'] as $key => &$library) {
        $library = str_replace('vactory', $theme_name, $library);
      }

      $data['libraries-override']['vactory/style'] = FALSE;
      $data['libraries-override']['vactory/script'] = FALSE;

      $yaml = Yaml::dump($data, 2);
      file_put_contents($theme_path . "/{$theme_name}.info.yml", $yaml);

      // THEME.libraries.yml
      $data = Yaml::parseFile($theme_path . "/{$theme_name}.libraries.yml");

      // css.
      if (isset($data['style']['css']['theme']['assets/css/vactory.style.css'])) {
        $data['style']['css']['theme']["assets/css/{$theme_name}.style.css"] = $data['style']['css']['theme']['assets/css/vactory.style.css'];
        unset($data['style']['css']['theme']['assets/css/vactory.style.css']);
      }

      // js.
      if (isset($data['script']['js']['assets/js/vactory.script.js'])) {
        $data['script']['js']["assets/js/{$theme_name}.script.js"] = $data['script']['js']['assets/js/vactory.script.js'];
        unset($data['script']['js']['assets/js/vactory.script.js']);
      }

      $yaml = Yaml::dump($data, 4);
      file_put_contents($theme_path . "/{$theme_name}.libraries.yml", $yaml);

      // config/install/{theme}.settings.yml
      $data = Yaml::parseFile($theme_path . "/config/install/{$theme_name}.settings.yml");
      $data['logo']['path'] = str_replace('vactory', $theme_name, $data['logo']['path']);
      $yaml = Yaml::dump($data, 2);
      file_put_contents($theme_path . "/config/install/{$theme_name}.settings.yml", $yaml);

      // config.json
      $data = file_get_contents($theme_path . '/config.json');
      $data = json_decode($data);

      $data->name = $theme_name;
      $data->css->file = "src/scss/{$theme_name}.style.scss";
      $data->js->file = "{$theme_name}.script.js";

      $data = json_encode($data, JSON_PRETTY_PRINT);
      file_put_contents($theme_path . '/config.json', $data);

    }
    else {
      exit(1);
    }
  }

}
