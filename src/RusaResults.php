<?php

/**
 * @file
 *  RusaResults.php
 *
 * @Creted 
 *  2018-02-25 - Paul Lieberman
 *
 * Gets and holds Results data
 */

namespace Drupal\rusa_api;

use Drupal\Core\Messenger;
use Drupal\rusa_api\Client\RusaClient;

/**
 * Gets Results data from backend
 *
 * @param $params should be key=mid val=$mid
 *
 */
class RusaResults {

  protected $results;

  public function __construct($params = []) {

    // Extract the member ID from the params
    if ($params['key'] == 'mid' && !empty($params['val'])) {
      $mid = $params['val'];
    }
    else {
      $messenger = \Drupal::messenger();
      $messenger->addMessage(t("Cannot get results without a RUSA #."), $messenger::TYPE_ERROR);
      return;
    }

    $client = new RusaClient();
    $this->results   = $client->getResults($mid);
  }


  public function getResults() {
    return $this->results;
  }


} // End of class
