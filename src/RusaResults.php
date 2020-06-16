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
use Drupal\rusa_api\Client\RusaResultsClient;

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

    $client = new RusaResultsClient();
    $data   = $client->get($mid);

    // Sort by date
    foreach ($data as $key => $result) {
      $results[$key] = $result;
      $asort[$key] = strtotime($result->date);
    }
    array_multisort($asort, SORT_NUMERIC, SORT_DESC,
                    $results);
    $this->results = $results;
  }


  public function getResults() {
    return $this->results;
  }


} // End of class
