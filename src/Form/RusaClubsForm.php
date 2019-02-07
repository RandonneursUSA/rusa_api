<?php

/**
 * @file
 *  RusaClubsForm.php
 *
 * @Creted 
 *  2017-05-14 - Paul Lieberman
 *
 * Read JSON from Perl
 */

namespace Drupal\rusa_api\Form;

use Drupal\rusa_api\Client\RusaClient;
use Drupal\Core\Form\FormBase;
use Drupal\Core\Form\FormStateInterface;

/**
 *
 */
class RusaClubsForm extends FormBase {

  // Required function
  public function getFormId() {
    return 'rusa_clubs_form';
  }

  /**
   *
   *
   */
  public function buildForm(array $form, FormStateInterface $form_state ) {

    // ACPcode can be passed as a query parameter
    $acpcode =  \Drupal::request()->query->get('acpcode');

    $form['acpcode'] = [
      '#type' => 'search',
      '#title' => $this->t('ACP Code'),
      '#default_value' => $acpcode,
    ];

    $form['actions']['submit'] = [
      '#type' => 'submit',
      '#value' => $this->t('Search'),
    ];

    // See if we have results to display
    if (isset($acpcode) || $acpcode = $form_state->getValue('acpcode')) {
      // Retrieve the data
      $clubs = $this->get_data($acpcode);

      // Build the form array
      $form['clubs'] = [
          '#type'   => 'table',
          '#sticky' => TRUE,
          '#header'  => [
            $this->t('Name'),
            $this->t('ACP Code'),
          ],
        ];

      foreach ($clubs as $club) {
        $rows[] = [
          $club->name,
          $club->acpcode,
        ];
      }
      $form['clubs']['#rows'] = $rows;
    }
    return $form;
  }

  public function submitForm(array &$form, FormStateInterface $form_state) {
    $form_state->setRebuild();
  }


  /**
   * Read member data from a gdbm file
   *
   */
  private function get_data($code) {
    $client = new RusaClient();
    $query = [
      'dbname'  => 'clubs',
      'key'     => 'acpcode',
      'val'     => 'code',
    ];
    $data = $client->get($query);
    return $data;
  }
}
