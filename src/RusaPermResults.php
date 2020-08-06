<?php

/**
 * @file
 *  RusaPermResults.php
 *
 * @Creted 
 *  2020-06-29 - Paul Lieberman
 *
 * Permanent Results 
 *
 * Drupal to Perm API for posting Perm results
 */

namespace Drupal\rusa_api;

use Drupal\rusa_api\Client\RusaClient;

/**
 * Permanent Results
 *
 */
class RusaPermResults {

    protected $results;

    public function __construct($results = []) {
        $this->results = $results;
    }

    // Post results to Perl
    public function post() {
        $client = new RusaClient();
        $response = $client->post_perm_results($this->results);
        return $response;
    }

} // End of class
