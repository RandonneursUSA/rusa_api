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
use Drupal\rusa_api\RusaEvents;
use Drupal\rusa_api\RusaRoutes;
use Drupal\rusa_api\RusaPermanents;

/**
 * Gets Results data from backend
 *
 * Reads data form several GDBM files
 *  results
 *  mresults
 *  rstatus
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
    
    // First get all results for this member
    $data = $client->get(['dbname' => 'results', 'key' => 'mid', 'val' => $mid ]);

    $uresults = [];
    foreach ($data as $result) {
      $uresults[$result->rid] = $result;
    }

    // Next we get the data from mresults
    $data = $client->get(['dbname' => 'mresults', 'key' => 'mid', 'val' => $mid]);

    // The result IDs are in a colon delimited field called rsidlist
    $rsids = explode(':', $data[0]->rsidlist);

    // Next we have to check rstatus for each result
    foreach ($rsids as $rsid) {
      $data = $client->get(['dbname' => 'rstatus', 'key' => 'rsid', 'val' => $rsid]);
      $result = [];
      if (strpos($rsid, 'TB') === FALSE) {
        // Brevet 
        $event            = $client->get(['dbname' => 'events', 'key' => 'eid',  'val' => $rsid]);
        $result['event']  = $event[0];
        $route            = $client->get(['dbname' => 'routes', 'key' => 'rtid', 'val' => $event[0]->rtid]);
        $result['route']  = $route[0];
        $result['type']   = $event[0]->type;
        $result['date']   = $event[0]->date;
        $result['dist']   = $event[0]->dist;
      }
      else {
        // Permanent
        $result['dist'] = $data[0]->dist;
        $result['date'] = $data[0]->date;
        $result['type'] = "RUSAT";
        $perm           = $client->get(['dbname' => 'permanents', 'key' => 'pid', 'val' => $data[0]->pid]);
        $result['perm'] = $perm[0];
      }

      // Only show results for this year
      $ymd = explode("/", $result['date']);
      if ($ymd[0] < date("Y") ) {
        continue;
      }

      // Go through the result id list and find the one for this user
      foreach (explode(':', $data[0]->ridlist) as $rid) {
        if (isset($uresults[$rid])) {
          $result['result'] = $uresults[$rid];
        }
      }

      // Finally save it
      $this->results[$rsid]  = $result; 
    }
  }


  public function getResultsData() {
    return $this->results;
  }

  public function getResultsFields() {
    // Cert No. Type   Km   Date  Route   Time
    $results = [];
    foreach ($this->results as $rsid => $result) {
      $results[$rsid]['cert']  = $result['result']->cert;
      $results[$rsid]['type']  = $result['type'];
      $results[$rsid]['dist']  = $result['dist'];
      $results[$rsid]['date']  = $result['date'];
      $results[$rsid]['route'] = $result['type'] == "RUSAT" ? $result['perm']->name : $result['route']->name;
      $results[$rsid]['time']  = $result['result']->time;
    }
    return $results;
  }



} // End of class
