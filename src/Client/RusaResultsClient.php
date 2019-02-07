<?php

namespace Drupal\rusa_api\Client;

class RusaResultsClient {
  /**
   */
  protected $httpClient;
  protected $base_uri;
  
  /**
   * Constructor.
   */
  public function __construct() {
    $this->httpClient = \Drupal::httpClient();
    $this->get_uri = "http://localhost/cgi-bin/results2json.pl";
    //$this->get_uri = "https://linode.rusa.org/cgi-bin/results2json.pl";
  }

  /**
   * Get the data from the back end
   *
   */
   public function get($query = NULL) {
     if (! $query) {
       return;
     }
     $qstring = '?' . $query;
     
     // Get the response
     $response = $this->httpClient->get($this->get_uri . $qstring, ['verify' => FALSE] );
     $json     = $response->getBody();
     $data     = json_decode($json);
     return $data;
   }
}
