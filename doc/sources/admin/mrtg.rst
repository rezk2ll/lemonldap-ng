MRTG monitoring
===============

:doc:`The status page<status>` can be read by
`MRTG <http://oss.oetiker.ch/mrtg/>`__ using the script **lmng-mrtg**
that can be found in manager example directory.

MRTG configuration example:

.. code-block:: shell

   ######################################################################
   # Multi Router Traffic Grapher -- Sample Configuration File
   ######################################################################
   # This file is for use with mrtg-2.5.4c

   # Global configuration
   WorkDir: /var/www/mrtg
   WriteExpires: Yes

   Title[^]: Traffic Analysis for

   # 128K leased line
   # ----------------
   #Title[leased]: a 128K leased line
   #PageTop[leased]: <H1>Our 128K link to the outside world</H1>
   #Target[leased]: 1:public@router.localnet
   #MaxBytes[leased]: 16000
   Target[test.example.com]: `/etc/mrtg/lmng-mrtg 172.16.1.2 https://test.example.com/status OK OK`
   Options[test.example.com]: nopercent, growright, nobanner, perminute
   PageTop[test.example.com]: <h1>Requests OK from test.example.com</h1>
   MaxBytes[test.example.com]: 1000000
   YLegend[test.example.com]: hits/minute
   ShortLegend[test.example.com]: &nbsp; hits/mn
   LegendO[test.example.com]: Hits:
   LegendI[test.example.com]: Hits:
   Legend2[test.example.com]: Hits per minute
   Legend4[test.example.com]: Hits max per minute
   Title[test.example.com]: Hits per minute
   WithPeak[test.example.com]: wmy

