<?php

/**
 * @file
 *  RusaApiForm.php
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
use Drupal\Core\Link;
use Drupal\Core\Url;

/**
 *
 */
class RusaMembersForm extends FormBase {

  // Required function
  public function getFormId() {
    return 'rusa_members_form';
  }

  /**
   *
   *
   */
  public function buildForm(array $form, FormStateInterface $form_state) {

    $form['query'] = [
      '#type' => 'search',
      '#title' => $this->t('RUSA Member #'),
    ];

    $form['actions']['submit'] = [
      '#type' => 'submit',
      '#value' => $this->t('Search'),
    ];

    // See if we have results to display
    if ($query = $form_state->getValue('query')) {
      // Retrieve the data
      $members = $this->get_data($query);
      // Build the form array
      $form['members'] = [
          '#type'   => 'table',
          '#sticky' => TRUE,
          '#header'  => [
            $this->t('First'),
            $this->t('Last'),
            $this->t('RUSA ID'),
            $this->t('Club ID'),
            $this->t('City'),
            $this->t('State'),
          ],
        ];

      foreach ($members as $member) {
        if ($member->mid === $query) {
          $rows[] = [
            $member->fname,
            $member->sname,
            $member->mid,
            Link::fromTextAndUrl($member->clubacp,
              Url::fromRoute(rusa_clubs, array('acpcode' => $member->clubacp))),
            $member->city,
            $member->state,
          ];
        }
      }
      $form['members']['#rows'] = $rows;
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
  private function get_data($mid) {
    $client = new RusaClient();
    $query = [
      'dbname'  => 'members',
      'key'     => 'mid',
      'val'     => $mid,
    ];
    $data = $client->get($query);
    return $data;
  }
}
