<?php

namespace Drupal\rusa_api\Client;

class RusaClient {
    /**
     */
    protected $httpClient;
    protected $base_uri;

    /**
     * Constructor.
     */
    public function __construct() {
        $this->httpClient = \Drupal::httpClient();
        // $this->get_uri = "https://rusa.org/cgi-bin/gdbm2json.pl";
        // $this->put_uri = "https://rusa.org/cgi-bin/post_routes.pl";
        $this->get_uri = "https://dev.rusa.org/cgi-bin/gdbm2json.pl";
        $this->put_uri = "https://dev.rusa.org//cgi-bin/post_routes.pl";
        $this->results_uri = "https://dev.rusa.org//cgi-bin/resultsubmit4_PF.pl";
        $this->pay_uri = "https://dev.rusa.org//cgi-bin/perm_pay.pl";
    }

    /**
     * Get the data from the back end
     *
     */
    public function get($query = NULL) {
        // Build up the query string if given
        // ----------------------------------
        $qstring = "";
        if (isset($query['dbname'])) {
            $qstring = '?' . $query['dbname'];
        }
        if (isset($query['key']) && isset($query['val'])) {
            $qstring .= "&" . $query['key'] . "=" . $query['val'];
        }

        // Get the response
        $response = $this->httpClient->get($this->get_uri . $qstring, ['verify' => FALSE] );
        $json     = $response->getBody();
        $data     = json_decode($json);
        return $data;
    }


    /**
     * Post the results to the back end
     *
     */
    public function put($data = []) {
        $json = json_encode($data);
        $request = $this->httpClient->post($this->put_uri, [
                'verify'    => FALSE,
                'json'      => $json,
        ]);
        return json_decode($request->getBody());
    }

    public function post_perm_results($data = []) {
    
        //  Send as a form    
        $request = $this->httpClient->post($this->results_uri,
            [
                'verify'      => FALSE,
                'form_params' => $data,
                'headers' => [
                    'Content-type' => 'application/x-www-form-urlencoded',
                ],
            ]);
        return json_decode($request->getBody());

    }



    /**
     * Post perm prog payment
     *
     */
    public function perm_pay($data = []) {
        $json = json_encode($data);
        $request = $this->httpClient->post($this->pay_uri, [
                'verify'    => FALSE,
                'json'      => $json,
        ]);
        return json_decode($request->getBody());
    }

} //End of Class
