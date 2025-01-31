Custom Drupal module for rusa.org
Author: Paul Lieberman

Moved to github/RandonneursUSA May 3, 2022 - PL - MFT

This module includes classes and methods used by all of the other rusa/ modules, mainly for database interaction. The Client classes currently use the GDBM2JSON gateway to get data from the GDBM files. In theory these could just be swapped for classes that use the entity API once the data is in Drupal, and none of the others would have to change.

## Requirements
Perl CGI modules
gdbm2json.pl
post_routes.pl
results2json.pl

## Permisions
Defines a long list of permissions that corespond to the backend capabilities table

## CSS and JS
These should be moved to a new custom theme

## Classes
--------------------

RusaApiForm     - Early development work, can be deleted
RusaClubs       - Methods to get club data 
RusaCountries   - Methods to get country data
RusaEvents      - Methods to get events data
RusaMembers     - Methods to get member data
RusaMessages    - A class for all textual messages. Hasn't worked out yet, but a good idea
RusaOfficials   - Methods to get official data
RusaPermanents  - Methods to get permanent data
RusaRegions     - Methods to get region data
RusaResults     - Methods to get results data
RusaResultsSlow - Original attempt to get results was way too slow
RusaRoutes      - Methods to get routes data
RusaStates      - Methods to get states data

Client/RusaClient        - The main interface to the GDBM data
Client/RusaResultsClient - Results needed a special case because they are so convoluted


Plugin/rest/resource/RusaApiResource - Early attempt at defining a REST resource. Not yet ready for prime time.

