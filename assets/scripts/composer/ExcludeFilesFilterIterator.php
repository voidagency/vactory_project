<?php

// phpcs:disable

/**
 * @file
 * Contains \VoidFactory\composer\ExcludeFilesFilterIterator.
 */

namespace VoidFactory\composer;

class ExcludeFilesFilterIterator extends \FilterIterator {

  public function accept() {
    $fileinfo = $this->getInnerIterator()->current();

    if (preg_match('/node_modules/', $fileinfo)) {
      return FALSE;
    }

    if (preg_match('/\.breakpoints\.yml/', $fileinfo)) {
      return FALSE;
    }

    if (preg_match('/includes/', $fileinfo)) {
      return FALSE;
    }

    if (preg_match('/\.theme/', $fileinfo)) {
      return FALSE;
    }

    return TRUE;
  }
}
