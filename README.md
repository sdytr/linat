# linat

*The LFE client library for the iNaturalist REST API*

<img src="resources/images/inaturalist-report-6-medium.png" />

## Table of Contents

* [Introduction](#introduction-)
  * [About iNaturalist](#about-recurly-)
  * [The LFE Client Library](#the-lfe-client-library-)
* [Dependencies](#dependencies-)
* [Installation](#installation-)
* [Usage](#usage-)
  * [Configuration](#configuration-)
  * [Starting linat](#starting-linat-)
  * [Authentication](#authentication-)
  * [Making Calls](#making-calls-)
    * [From LFE](#from-lfe-)
    * [From Erlang](#from-erlang-)
    * [Options](#options-)
  * [Working with Results](#working-with-results-)
    * [Format](#format-)
    * [get-data](#get-data-)
    * [get-in](#get-in-)
    * [get-linked](#get-linked-)
    * [map and foldl](#map-and-foldl-)
    * [Composing Results](#composing-results-)
    * [Batched Results and Paging](#batched-results-and-paging-)
    * [Relationships and Linked Data](#relationships-and-linked-data-)
  * [Creating Payloads](#creating-payloads-)
  * [Handling Errors](#handling-errors-)
    * [Service Errors](#service-errors-)
    * [HTTP Errors](#http-errors-)
    * [linat Errors](#linat-errors-)
    * [lhc Errors](#lhc-errors-)
  * [Logging](#logging-)
* [The API](#the-api-)
  * [Comments](#comments-)
  * [Identifications](#identifications-)
  * [Observations](#observations-)
  * [Places](#places-)
  * [Projects](#projects-)
  * [Users](#users-)


## Introduction [&#x219F;](#table-of-contents)

### About iNaturalist [&#x219F;](#table-of-contents)

From the iNaturalist [docs site](https://www.inaturalist.org/pages/developers/) (and [here](https://www.inaturalist.org/pages/api+reference)):

<blockquote>iNaturalist has a lot to offer fellow programmers interested in biodiversity, from data to software to infrastructure.

The iNat API is a set of REST endpoints that can be used to read data from iNat and write data back on the behalf of users. Data can be retrieved in different formats. Read-only endpoints generally do not require authentication, but if you want to access data like unobscured coordinates on behalf of users or write data to iNat, you will need to make authenticated requests.
</blockquote>

### The LFE Client Library [&#x219F;](#table-of-contents)

The LFE client library for the iNaturalist REST service is based upon [lhc](https://github.com/sdytr/lhc), the simple HTTP client for LFE. OAuth support is
provided by the [loauth](https://github.com/sdytr/loauth) library.


## Dependencies [&#x219F;](#table-of-contents)

To use linat, the following are required:

* Erlang (preferably a recent version)
* lfetool (from the [dev-v1 branch](https://github.com/lfe/lfetool/tree/dev-v1#dev-))
* rebar (used by lfetool and the linat ``Makefile``)
* Command-line developer tools (e.g., ``make``)

Before proceding, be sure to have those installed.


## Installation [&#x219F;](#table-of-contents)

Just add it to your ``rebar.config`` deps:

```erlang
  {deps, [
    ...
    {linat, ".*",
      {git, "git@github.com:sdytr/linat.git", "master"}}
      ]}.
```

And then do the usual:

```bash
    $ make compile
```


## Usage [&#x219F;](#table-of-contents)

### Configuration [&#x219F;](#table-of-contents)

The LFE iNat library supports two modes of configuration:
* OS environment variables
* the use of ``~/.inat/lfe.ini``

OS environment variables take precedence over values in the configuration file.
If you would like to use environment variables, the following may be set:

* ``INAT_APP_ID``
* ``INAT_SECRET``
* ``INAT_USER``
* ``INAT_PASS``

However, you have the option of using values stored in a configuration file, instead.
This project comes with a sample configuration file you can copy and then edit:

```bash
cp sample-lfe.ini ~/.inat/lfe.ini
```

Or you can just use the following as a template:

```ini
[REST API]
app-id = GFEDCBA9876543210
secret = abcdef123456
user = your iNaturalist login username
pass = your iNaturalist password
```

If neither of these methods is used to set a given variable, an error will be returned.


### Starting ``linat`` [&#x219F;](#table-of-contents)

The ``make`` targets for both the LFE REPL and the Erlang shell start linat
automatically. If you didn't use either of those, then you will need to
execute the following before using linat:

```lisp
> (linat:start)
(#(gproc ok)
 #(econfig ok)
 #(inets ok)
 #(ssl ok)
 #(lhttpc ok))
```
At that point, you're ready to start making calls.

If you're not in the REPL and you will be using this library programmatically,
you will want to make that call when your application starts.


### Authentication [&#x219F;](#table-of-contents)

In your OS shell, export your iNat API key and your subdomain, e.g.:

```bash
$ export INAT_APP_ID=GFEDCBA9876543210
$ export INAT_SECRET=abcdef123456
$ export INAT_USER=...
$ export INAT_PASS=...
```

Or be sure to have these defined in your ``~/.inat/lfe.ini`` file:

```ini
[REST API]
app-id = GFEDCBA9876543210
secret = abcdef123456
user = your iNaturalist login username
pass = your iNaturalist password
```

With one or both of these in place, you can now login and obtain your
token:

```lisp
> (set token (linat-auth:get-token))
"15bc50777bfcf8137348ade0bb03e2203cc0997fbeaffcc760963e2e71044825"
```


### Making Calls [&#x219F;](#table-of-contents)

This ``README`` won't document all the API details availale from the iNat service, as
that is already done by the folks at iNaturalist [here](https://www.inaturalist.org/pages/api+reference).
However, see below for some example usage to get starting using ``linat``
quickly.


#### From LFE [&#x219F;](#table-of-contents)

Calls from LFE are pretty standard:

```bash
$ make repl-no-deps
```

```lisp
> (linat:get-obs `(#(project 1234)))
#(ok ...)
```

#### From Erlang [&#x219F;](#table-of-contents)

Through written in LFE, the rcrly API is 100% Erlang Core compatible. You use
it just like any other Erlang library.

```bash
$ make shell-no-deps
```

```erlang
1> linat:'get-obs([{project, 1234}]).
{ok, ...}
```

#### Options [&#x219F;](#table-of-contents)

The following options may be passed to any API call:

* ``return`` - what format the client calls should take. Can be one of
  ``json``, ``csv``, ``dwc``, ``kml``, ``atom``, ``widget``, or ``full``; the default  is ``json``.
  Using the ``full`` format option will return JSON data as well as the complete HTTP
  response from the server (headers, status, etc.)
* ``log-level`` - sets the log level on-the-fly, for easy debugging on a
  per-request basis
* ``endpoint`` - whether the request being made is against an API endpoint
  or a raw URL (defaults to ``true``) (useful for when you need to make a request to a
  manually-created URL, as opposed to the default where linat creates the URL from
  path segments internally)


##### ``return`` [&#x219F;](#table-of-contents)

When the ``return-type`` is set to ``json`` (the default), the data from the
response is what is returned:

```lisp
> (rcrly:get-account 1 '(#(return-type json)))
#(ok
  (#(adjustments ...)
   #(invoices ...)
   #(subscriptions ...)
   #(transactions ...)
   #(account_code () ("1"))
   ...
   #(address ...)
   ...))
```

When the ``return-type`` is set to ``full``, the response is annotated and
returned:

```lisp
> (rcrly:get-account 1 '(#(return-type full)))
#(ok
  (#(response ok)
   #(status #(200 "OK"))
   #(headers ...)
   #(body
     (#(tag "account")
      #(attr (#(href "https://yourname.recurly.com/v2/accounts/1")))
      #(content
        #(account
          (#(adjustments ...)
           #(invoices ...)
           #(subscriptions ...)
           #(transactions ...)
           ...
           #(account_code () ("1"))
           ...
           #(address ...)
           ...)))
      #(tail "\n")))))
```


##### ``log-level`` [&#x219F;](#table-of-contents)

```lisp
(rcrly:get-account 1 '(#(log-level debug)))
```

##### ``endpoint`` [&#x219F;](#table-of-contents)

If you wish to make a request to a full URL, you will need to pass the option
``#(endpoint false)`` to override the default behaviour of the rcrly library
creating the URL for you, based upon the provided endpoint.

In other words, one would normally make this sort of call:

```lisp
> (rcrly:get "/some/recurly/endpoint")
```

And the ``endpoint`` option is needed if you want to access a full URL:

```lisp
> (set options '(#(endpoint false)))
> (rcrly:get "https://some.domain/path/to/resource" options)
```


##### Options for lhttpc [&#x219F;](#table-of-contents)

If you wish to pass general HTTP client options to lhttpc, then you will need to use
``rcrly-httpc:request/7``, which takes the following arguments:

```
endpoint method headers body timeout options lhttpc-options
```

where ``options`` are the rcrly options discussed above, and ``lhttpc-options``
are the regular lhttpc options, the most significant of which are:

* ``connect_options`` - a list of terms
* ``send_retry`` - an integer
* ``partial_upload`` - an integer (window size)
* ``partial_download`` - a list of one or both of ``#(window_size N)`` and ``#(part_size N)``
* ``proxy`` - a URL string
* ``proxy_ssl_options`` - a list of terms
* ``pool`` - pid or atom


### Working with Results [&#x219F;](#table-of-contents)

All results in rcrly are of the form ``#(ok ...)`` or ``#(error ...)``, with the
elided contents of those tuples changing depending upon context. This is the
standard approach for Erlang libraries, so should be quite familiar to users.

iNat's API is XML-based; the rcrly API inherits some of its characteristics
from this fact. In particular, data structures representing the parsed XML data
are regularly returned by rcrly calls. Parsed rcrly results have the following:

* a tag
* attributes
* contents (which may itself contain nested tag/attrs/contents)

As such, many results are often 3-tuples. rcrly includes functions (see below)
for working with this 3-tuple data.


#### Multi-Valued Results

By multi-valued results, we mean items in a list -- many rcrly API calls will
return a list of items, for example, ``get-all-invoices/0``, ``get-plans/0``, or
``get-accounts/0``. These results are of the following form:

```lisp
#(ok
  #(accounts
    (...) ; attributes
    (#(account
        (...) ; attributes
        (...) ; child elements
        )
     #(account ...)
     #(account ...)
     ...)))
```

The rcrly library provides ``map`` and ``foldl`` functions for easily working
with these results.


#### Single-Valued Results

By single-value results, we mean API calls which *do not* return a list of
values, but intstead return a single-item data structure. Examples of API calls
which do this are ``get-account/1``, ``get-billing-info/1``, ``get-plan/1``,
etc. The results for those functions have the following form:

```lisp
#(ok
  #(account
    (...) ; attributes
    (...) ; child elements
    ))
```

The rcrly library provides functions like ``get-in`` and ``get-linked`` for
easily working with these results.


#### Format [&#x219F;](#table-of-contents)

As noted above, the format of the results depend upon what value you have passed
as the ``return-type``; by default, the ``data`` type is passed and this simply
returns the data requested by the particular API call (not the headers, HTTP
status, body, XML conversion info, etc. -- if you want that, you'll need to pass
the ``full`` value associated with the ``return-type``).

The API calls return XML that has been parsed and converted to LFE data
structures by the [erlsom](https://github.com/willemdj/erlsom) library.

For instance, here's what a standard iNat JSON result looks like:

```xml
<account href="https://yourname.recurly.com/v2/accounts/1">
  <adjustments href="https://yourname.recurly.com/v2/accounts/1/adjustments"/>
  <billing_info href="https://yourname.recurly.com/v2/accounts/1/billing_info"/>
  <invoices href="https://yourname.recurly.com/v2/accounts/1/invoices"/>
  <redemption href="https://yourname.recurly.com/v2/accounts/1/redemption"/>
  <subscriptions href="https://yourname.recurly.com/v2/accounts/1/subscriptions"/>
  <transactions href="https://yourname.recurly.com/v2/accounts/1/transactions"/>
  <account_code>1</account_code>
  <state>active</state>
  <username nil="nil"></username>
  <email>verena@example.com</email>
  <first_name>Verena</first_name>
  <last_name>Example</last_name>
  <company_name></company_name>
  <vat_number nil="nil"></vat_number>
  <tax_exempt type="boolean">false</tax_exempt>
  <address>
    <address1>108 Main St.</address1>
    <address2>Apt #3</address2>
    <city>Fairville</city>
    <state>WI</state>
    <zip>12345</zip>
    <country>US</country>
    <phone nil="nil"></phone>
  </address>
  <accept_language nil="nil"></accept_language>
  <hosted_login_token>a92468579e9c4231a6c0031c4716c01d</hosted_login_token>
  <created_at type="datetime">2011-10-25T12:00:00</created_at>
</account>
```

And here is that same result from the LFE rcrly library:

```lisp
#(account
  (#(href "https://yourname.recurly.com/v2/accounts/1"))
  (#(adjustments
     (#(href "https://yourname.recurly.com/v2/accounts/1/adjustments"))
     ())
   #(invoices
     (#(href "https://yourname.recurly.com/v2/accounts/1/invoices"))
     ())
   #(subscriptions
     (#(href "https://yourname.recurly.com/v2/accounts/1/subscriptions"))
     ())
   #(transactions
     (#(href "https://yourname.recurly.com/v2/accounts/1/transactions"))
     ())
   #(account_code () ("1"))
   #(state () ("active"))
   #(username () ())
   #(email () ("verena@example.com"))
   #(first_name () ("Verena"))
   #(last_name () ("Example"))
   #(company_name () ())
   #(vat_number (#(nil "nil")) ())
   #(tax_exempt (#(type "boolean")) ("false"))
   #(address ()
     (#(address1 () ("108 Main St."))
      #(address2 () ("Apt #3"))
      #(city () ("Fairville"))
      #(state () ("WI"))
      #(zip () ("12345"))
      #(country () ("US"))
      #(phone (#(nil "nil")) ())))
   #(accept_language (#(nil "nil")) ())
   #(hosted_login_token () ("a92468579e9c4231a6c0031c4716c01d"))
   #(created_at (#(type "datetime")) ("2011-10-25T12:00:00"))))
```

The rcrly library offers a couple of convenience functions for extracting data
from this sort of structure -- see the next two sections for more information
about data extraction.

#### ``get-data`` [&#x219F;](#table-of-contents)

The ``get-data`` utility function is provided in the ``rcrly`` module and is
useful for extracing response data returned from client requests made with
the ``full`` option. It assumes a nested property list structure with the
``content`` key in the ``body``'s property list.

Example usage:

```lisp
> (set `#(ok ,results) (rcrly:get-accounts `(#(return-type full))))
#(ok
  (#(response ok)
   #(status #(200 "OK"))
   #(headers (...))
   #(body
     (#(tag "accounts")
      #(attr (#(type "array")))
      #(content
        #(accounts ...))))))

> (rcrly:get-data results)
#(accounts
  (#(type "array"))
  (#(account ...)
   #(account ...)))
```

Though this is useful when dealing with response data from ``full`` the return
type, you may find that it is more convenient to use the default ``data`` return
type with the ``rcrly:get-in`` function instead, as it allows you to extract
just the data you need. See below for an example.


#### ``get-in`` [&#x219F;](#table-of-contents)

The utillity function ``rcrly:get-in`` is inspired by the Clojure ``get-in``
function, but in this case, tailored to work with the rcrly results which have
been converted from XML to LFE/Erlang data structures. With a single call, you
are able to retrieve data which is nested at any depth, providing just the keys
needed to locate it.

Here's an example:

```lisp
> (set `#(ok ,account) (rcrly:get-account 1))
#(ok
  #(account
    (#(href ...))
    (#(adjustments ...)
    ...
    #(address ()
     (...
      #(city () ("Fairville"))
      ...))
    ...)))
> (rcrly:get-in '(account address city) account)
"Fairville"
```

The ``city`` field is nested in the ``address`` field. The ``address`` data
is nested in the ``account``.


#### ``get-linked`` [&#x219F;](#table-of-contents)


In the iNat REST API, data relationships are encoded in media links, per
common best REST practices. Linked data may be retreived easily using the
``get-linked/2`` utility function (analog to the ``get-in/2`` function).

Here's an example showing getting account data, and then getting data
which is linked to the account data via ``href``s:

```lisp
> (set `#(ok ,account) (rcrly:get-account 1))
#(ok
  #(account ...))
> (rcrly:get-linked '(account transactions) account)
#(ok
  #(transactions
    (#(type "array"))
    (#(transaction ...)
     #(transaction ...)
     #(transaction ...)
     ...)))
```


#### ``map`` and ``foldl`` [&#x219F;](#table-of-contents)

Recurly's API is XML-based, so parsed results have the following:
 * a tag
 * attributes
 * contents (which may itself contain nested tag/attrs/contents)

The ``map/2`` and ``foldl/3`` functions provided by linat aim to make working
with these results easier, especially for iterating through multi-valued
results.

It is important to note: ``map/2`` and ``foldl/3`` both take a *complete
result* -- this inlcudes the ``#(ok ...)``.

Here is an example usage for ``map/2`` that lists all the plan names in the
system:

```lisp
> (linat:map
    (lambda (x)
      (linat:get-in '(plan name) x))
    (linat:get-plans))
```
```
("Silver Plan" "Gold plan" "30-Day Free Trial")
```

Here is an example for ``foldl/3`` that gets the total of all invoices
(ignoring currency type), starting with an "add" function:

```lisp
> (defun add-invoice (invoice subtotal)
    (+ subtotal
      (/ (list_to_integer
           (linat:get-in '(invoice total_in_cents) invoice))
         100)))
add-invoice
```

Now let's use that in the ``linat:foldl/3`` function:

```lisp
> (linat:foldl
    #'add-invoice/2
    0
    (linat:get-all-invoices))
```
```
120.03
```


#### Composing Results [&#x219F;](#table-of-contents)

This section might be more accurately called "processing results through
function composition" but that was a bit long. We hope you'll forgive the
poetic license we took!

With that said, here's an example of a potential "data flow" using function
composition to get the following:

* get a list of all the accounts
* for each account, get all of its transactions
* for each transaction, check to see that it's not recurring
* return the transaction id for each recurring transation which has a "success" state

We're going to use the lutil ``->>`` macro for this, which is included in
``linat.lfe``, so we'll slurp that file:

```lisp
> (slurp "src/linat.lfe")
#(ok linat)
>
```

If you'd like to use the ``->>`` macro in your own modules, be sure to include
it there:

```lisp
(include-lib "lutil/include/compose.lfe")
```

We're going to need some helper functions:

```lisp
> (defun get-xacts (acct)
    (linat:get-linked '(account transactions) acct))
get-xacts
> (defun check-xacts (xacts)
    (linat:map #'check-xact/1 xacts))
check-xacts
> (defun check-xact (xact)
    (if (=/= (linat:get-in '(transaction recurring) xact) "true")
        (if (=:= (linat:get-in '(transaction status) xact) "success")
            (linat:get-in '(transaction uuid) xact))))
check-xact
> (defun id?
    ((id) (when (is_list id))
     'true)
    ((x) x))
id?
>
```

Now we can perform our defined task (keep in mind that when using the ``->>``
macro, the output of the first function is added as a final argument to the
next function):

```lisp
> (->> (linat:get-accounts)        ; this returns a multi-valued result
       (linat:map #'get-xacts/1)   ; this returns a list of multi-valued results
       (lists:map #'check-xacts/1) ; this returns a list of lists
       (lists:foldl #'++/2 '())    ; this flattns the list, preserving strings
       (lists:filter #'id?/1))     ; just returns results that are ids
```
```
("2d9d1054c2716a3d38260146d28ebc7c"
 "2dc20791440f9313a877414fe1a6f7a4"
 "2dc2076ab55c2054cfaf3b427589437a"
 "2dbc6c2d09c5aed53a9ede41138f63df"
 "2dbc6c17524ca5cda869684a6bb7aae3")
```

Of the 12 transactions in the accounts this was tested against, those five
satisfied the criteria of being non-recurring and in a successful state.

This was intended to show the possibilities of composition, and the following
should be noted about the above code:
 * by getting the accounts first, we could have performed additional checks
   against account data; and
 * if we had really wanted to check all the transactions without looking
   at any of the account data, we would have simply used the
   ``get-all-transactions`` linat API call.


#### Batched Results and Paging [&#x219F;](#table-of-contents)

TBD


#### Relationships and Linked Data [&#x219F;](#table-of-contents)

In the Recurly REST API, data relationships are encoded in media links, per
common best REST practices. Linked data may be retreived easily using the
``get-linked/2`` utility function (analog to the ``get-in/2`` function).

For more information, see the ``get-linked`` section above.

### Creating Payloads [&#x219F;](#table-of-contents)

Payloads for ``PUT`` and ``POST`` data in the Recurly REST API are XML
documents. As such, we need to be able to create XML for such things as
update actions. To facilitate this, The LFE linat library provides
XML-generating macros. in the REPL, you can ``slurp`` the ``linat-xml``
module, and then have access to them. For instance:

```lisp
> (slurp "src/linat-xml.lfe")
#(ok linat-xml)
```

Now you can use the linat macros to create XML in LFE syntax:

```lisp
> (xml/account (xml/company_name "Bob's Red Mill"))
"<account><company_name>Bob's Red Mill</company_name></account>"
```

This also works for modules that will be genereating XML payloads: simply
``include-lib`` them like they are in ``linat-xml``:

```lisp
(include-lib "linat/include/xml.lfe")
```

And then they will be available in your module.

Here's a sample payload from the
[Recurly docs](https://docs.recurly.com/api/billing-info#update-billing-info-credit-card)
(note that multiple children need to be wrapped in a ``list``):

```lisp
> (xml/billing_info
    (list (xml/first_name "Verena")
          (xml/last_name "Example")
          (xml/number "4111-1111-1111-1111")
          (xml/verification_value "123")
          (xml/month "11")
          (xml/year "2015")))
"<billing_info>
  <first_name>Verena</first_name>
  <last_name>Example</last_name>
  <number>4111-1111-1111-1111</number>
  <verification_value>123</verification_value>
  <month>11</month>
  <year>2015</year>
</billing_info>"
```


### Handling Errors [&#x219F;](#table-of-contents)

As mentioned in the "Working with Results" section, all parsed responses from
Recurly are a tuple of either ``#(ok ...)`` or ``#(error ...)``. All processing
of linat results should pattern match against these typles, handling the error
cases as appropriate for the application using the linat library.


#### Recurly Errors [&#x219F;](#table-of-contents)

The Recurly API will return errors under various circumstances. For instance,
an error is returned when attempting to look up billing information with a
non-existent account:

```lisp
> (set `#(error ,error) (linat:get-billing-info 'noaccountid))
#(error
  #(error ()
    (#(symbol () ("not_found"))
     #(description
       (#(lang "en-US"))
       ("Couldn't find Account with account_code = noaccountid")))))
```

You may use the ``get-in`` function to extract error information:

```lisp
> (linat:get-in '(error description) error)
"Couldn't find Account with account_code = noaccountid"
```

#### HTTP Errors [&#x219F;](#table-of-contents)

Any HTTP request that generates an HTTP status code equal to or greater than
400 will be converted to an error. For example, requesting account information
with an id that no account has will generate a ``404 - Not Found`` which will
be converted by linat to an application error:

```lisp
> (set `#(error ,error) (linat:get-account 'noaccountid))
#(error
  #(error ()
    (#(symbol () ("not_found"))
     #(description
       (#(lang "en-US"))
       ("Couldn't find Account with account_code = noaccountid")))))
```
```lisp
> (linat:get-in '(error description) error)
"Couldn't find Account with account_code = noaccountid"
```


#### linat Errors [&#x219F;](#table-of-contents)

[more to come, examples, etc.]


#### lhttpc Errors [&#x219F;](#table-of-contents)

[more to come, examples, etc.]


### Logging [&#x219F;](#table-of-contents)

linat uses the LFE logjam library for logging. The log level may be configured
in two places:

* an ``lfe.config`` file (this is the standard location for logjam)
* on a per-request basis in the ``options`` arguement to API calls

The default log level is ``emergency``, so you should never notice it's there
(unless, of course, you have lots ot logging defined for the ``emergency``
level ...). The intended use for linat logging is on a per-request basis for
debugging purposes (though, of course, this may be easily overridden in your
application code by setting the log level you desire in the ``lfe.config``
file).

Note that when passing the ``log-level`` option in an API call, it sets the
log level for the logging service which is running in the background. As such,
the ``log-level`` option does not need to be passed again until you wish to
change it. In other words, when passed as an option, it is set for all future
API calls.

For more details on logging per-request, see the "Options" section above.


## The API [&#x219F;](#table-of-contents)

Each API call has a default arity and then an arity+1 where the "+1" is an
argument for linat client options (see the "Options" section above).

For each of the API functions listed below, be sure to examine the linked
Recurly documentation for information about payloads.

* [The API](#the-api-)
  * [Comments](#comments-)
  * [Identifications](#identifications-)
  * [Observations](#observations-)
  * [Places](#places-)
  * [Projects](#projects-)
  * [Users](#users-)


### Comments [&#x219F;](#table-of-contents)

Recurly [Comments documentation](https://www.inaturalist.org/pages/api+reference#post-comments)

#### ``add-comment``

Takes three arguments:

```lisp

```

#### ``update-comment``

Takes ID argument:

```lisp

```

#### ``delete-comment``

Takes ID argument:

```lisp

```


### Identifications [&#x219F;](#table-of-contents)

Recurly [Identifications documentation](https://www.inaturalist.org/pages/api+reference#post-identifications)


### Observations [&#x219F;](#table-of-contents)

Recurly [Observations documentation](https://www.inaturalist.org/pages/api+reference#get-observations)


### Places [&#x219F;](#table-of-contents)

Recurly [Places documentation](https://www.inaturalist.org/pages/api+reference#get-places)


### Projects [&#x219F;](#table-of-contents)

Recurly [Projects documentation](https://www.inaturalist.org/pages/api+reference#get-projects)


### Users [&#x219F;](#table-of-contents)

Recurly [Users documentation](https://www.inaturalist.org/pages/api+reference#post-users)
