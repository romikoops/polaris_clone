The “SACO” Format
=================

The “SACO” Format (SF) is a compromise between the in use pricing sheet
format used by SACO and a machine readable format our code can parse.
The result is a complex sheet that at first can seem daunting but can
easily be turned into a powerful rate upload tool if used correctly.

Sheet Schema
------------

The SF is comprised of two main sections - the route and service columns
present in other pricing uploaders, three dedicated rate columns for the
3 main cargo types (20DC, 40DC, 40HQ) and the dynamic fee columns. Each
row represents a pricing by itself, complete with multiple fees, for
this month and the next, for each of the three cargo classes.

Route And Service Identification Columns:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-  DESTINATION_COUNTRY - Full name of the destination country

-  DESTINATION_LOCODE - UN/LOCODE for the destination

-  DESTINATION_HUB - Name of the Hub at the destination

-  TERMINAL - Terminal of the Hub if present (NB used to find the
      correct Hub)

-  TRANSSHIPMENT_VIA - String representing the Transshipment point(s)

-  CARRIER - name of the carrier providing the service

-  ORIGIN_LOCODE - UN/LOCODE of the origin port

-  EFFECTIVE_DATE - date the rate comes into effect

-  EXPIRATION_DATE - last date the the rate is valid

-  REMARKS: (usually last column) notes to be attached to the Pricing

Fixed Rate Columns
~~~~~~~~~~~~~~~~~~

For every common cargo class we provide a dedicated column for
specifying the Basic Ocean Freight (BAS) or default freight fee

Dynamic Columns
~~~~~~~~~~~~~~~

The rest of the sheet is comprised of dynamic columns with their
function being defined by their headers.

The system is set up to let fee data span multiple columns using the
prefixes “CURR_” and “NEXT_” and the suffixes “MONTH” and “FEE”.

In general the headers follow this pattern with any section of the
pattern being optional

-  OPERATOR:

   -  CURR_MONTH: Indicates what month the “CURR” fee applies to

   -  NEXT_MONTH: Indicates what month the “NEXT” fee applies to

   -  CURR_FEE: Indicates this is the value for the “CURR” month

   -  NEXT_FEE: Indicates this is the value for the “NEXT” month

   -  INT: Column is for internal use only and should not be persisted

   -  NOTE: Column is storing a note rather than rate data

-  CARGO_CLASS: As we are primarily targeting 3 cargo classes we can
      target different “Pricings” and set different values for the same
      fee

   -  20: Maps to \`fcl_20\`

   -  40: Maps to both \`fcl_40\` and \`fcl_40_hq\`

-  FEE CODE: The name and code of the fee.

   -  The text is converted to lowercase and used as the code

   -  The text is humanized (swap underscores for spaces and capitalize
         first letter) to become the fee name (if no ChargeCategory
         exists for that fee code already)

General Notes and Limitations:
------------------------------

Validity dates:
~~~~~~~~~~~~~~~

The period defined in the columns EFFECTIVE_DATE and EXPIRATION_DATE is
the only period where we will build and insert fees for. This means if
the month described in the CURR_MONTH or NEXT_MONTH columns lies outside
that period the fee will not be included in the final pricing.

The rule can be expressed as EFFECTIVE_DATE < CURR_MONTH < NEXT_MONTH <
EXPIRATION_DATE

Included Fees:
~~~~~~~~~~~~~~

Some fees are supposed to be displayed as a separate line item despite
the actual cost being included in the calculation of the main fee. This
can be achieved in 2 ways:

-  Cell value “incl”

   -  This approach is better when the fee is not always included

-  “fee code” prefixed with “included_”

   -  Use this approach when no rows have any values for that fee yet it
         must still be displayed
