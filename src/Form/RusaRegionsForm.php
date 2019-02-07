<?php
/**
 * @file
 *  RusaRegionsForm.php
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
class RusaRegionsForm extends FormBase {

  // Required function
  public function getFormId() {
    return 'rusa_api_form';
  }

  /**
   *
   *
   */
  public function buildForm(array $form, FormStateInterface $form_state) {

    $form['query'] = [
      '#type' => 'search',
      '#title' => $this->t('State Abbreviation'),
    ];

    $form['actions']['submit'] = [
      '#type' => 'submit',
      '#value' => $this->t('Search'),
    ];

    // See if we have results to display
    if ($query = $form_state->getValue('query')) {
      // Retrieve the data
      $regions = $this->get_data($query);

      // Build the form array
      $form['regions'] = [
          '#type'   => 'table',
          '#sticky' => TRUE,
          '#header'  => [
            $this->t('City'),
            $this->t('State'),
            $this->t('RBA ID'),
            $this->t('Club ID'),
          ],
        ];

      foreach ($regions as $region) {
        if ($region->state === $query) {
          $rows[] = [
            $region->city,
            $region->state,
            $region->rbaid,
            $region->orgclub,
          ];
        }
      }
      $form['regions']['#rows'] = $rows;
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
  private function get_data($state) {
    $client = new RusaClient();
    $query = [
      'dbname'  => 'regions',
      'key'     => 'state',
      'val'     => $state,
    ];
    $data = $client->get($query);
    return $data;
  }
}
