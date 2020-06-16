<?php

namespace Drupal\rusa_api\Routing;

use Drupal\Core\Routing\RouteSubscriberBase;
use Symfony\Component\Routing\RouteCollection;

/**
 * Class JsonapiLimitingRouteSubscriber.
 *
 * Remove all DELETE routes from jsonapi resources to protect content.
 *
 * Remove POST and PATCH routes from jsonapi resources except for those
 * we want end users to create and update via the decoupled API.
 */
class RusaRouteSubscriber extends RouteSubscriberBase {

  /**
   * {@inheritdoc}
   */
  protected function alterRoutes(RouteCollection $collection) {
    $mutable_types = $this->mutableResourceTypes();
    foreach ($collection as $name => $route) {
      $defaults = $route->getDefaults();
      if (!empty($defaults['_is_jsonapi']) && !empty($defaults['resource_type'])) {
        $methods = $route->getMethods();
        if (in_array('DELETE', $methods)) {
          // We never want to delete data, only unpublish.
          $collection->remove($name);
        }
        else {
          $resource_type = $defaults['resource_type'];
          if (empty($mutable_types[$resource_type])) {
            if (in_array('POST', $methods) || in_array('PATCH', $methods)) {
              $collection->remove($name);
            }
          }
        }
      }
    }
  }

  /**
   * Get mutable resource types, exposed to user changes via API.
   *
   * @return array
   *   List of mutable jsonapi resource types as keys.
   */
  public function mutableResourceTypes(): array {
    return [
      'node--article' => TRUE,
      'node--document' => TRUE,
      // 'custom_entity--custom_entity' => TRUE,
    ];
  }

}
