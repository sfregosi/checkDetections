# This is an Ishmael settings file.  It is okay to edit it with a text
# editor or word processor, provided you save it as TEXT ONLY.  It's
# generally safe to change the values here in ways that seem reasonable,
# though you could undoubtedly make Ishmael fail with some really poor
# choices of values.
# 
# Also:
#    * Keep each line in its original section (Unit) or it will be ignored.
#
#    * A line beginning with '#', like this one, is a comment.
#
#    * Spaces and capitalization in parameter names ARE significant.
#
#    * If you delete a line containing a certain parameter, then loading
#      this settings file will not affect Ishmael's current value of that
#      parameter.  So you can create a settings file with only a handful of
#      lines for your favorite values, and when you load that file, it will
#      set those parameters and leave everything else alone.
#
#    * When you save settings, beware that ALL parameter values are written
#      out, not just the ones you may have set in your parameters file.
#
#    * Ishmael's default settings file -- the one it loads at startup -- is
#      called IshDefault.ipf .


Unit: Spectrogram calculation, prefs version 1
    frame size, samples  = 16
    frame size, sec      = 0.0058049886
    zero pad             = 0
    hop size             = 2
    window type          = Hamming
    keep same duration   = true
    quadratic scaling    = false

Unit: Equalization, prefs version 1
    equalization enabled = true
    equalization time    = 0.5
    floor enabled        = true
    floor is automatic   = true
    gram floor value     = 0.208
    ceiling enabled      = true
    ceiling is automatic = true
    gram ceiling value   = 0.65386504

Unit: Energy sum, prefs version 1
    enabled              = true
    lower frequency bound = 2000
    upper frequency bound = 12000
    ratio enabled        = false
    ratio lower freq bound = 200
    ratio upper freq bound = 400

Unit: Tonal detection 1, prefs version 1
    enabled              = false
    lower frequency bound = 1000
    upper frequency bound = 2000
    base percentage      = 50
    height above base    = 0
    peak neighborhood    = 100
    peak min difference  = 100
    line fit duration    = 0.2
    minimum duration     = 0.5
    minimum independent dur = 0.1

Unit: Spectrogram correlator, prefs version 1
    enabled              = false
    kernel               = <NULL>
    kernel bandwidth     = 100

Unit: Matched filter, prefs version 1
    enabled              = false
    filter file name     = 
    min detected freq    = 0
    max detected freq    = +INF

Unit: Sequence recognition, prefs version 1
    sumautocorr enabled  = false
    sac window length    = 20
    sac hop size fraction = 0.050000001
    sac min period       = 0.30000001
    sac max period       = 1.2
    use old method       = false

Unit: Detector, prefs version 1
    time averaging enabled = true
    time averaging constant = 0.0099999998
    detection threshold  = 0.050000001
    min call duration    = 0
    max call duration    = 0.1
    detection neighborhood = 0
    detection channels   = 1000000000000000000000000000000000000000000000000000000000000000
    time before call     = 0.015
    time after call      = 0.015
    retrigger            = false
    display amplitude min = 0.01680002
    display amplitude max = 0.11680003
    old nbd method       = false
    Teager-Kaiser enabled = false

Unit: Spectrogram display, prefs version 1
    brightness           = 0.14399999
    contrast             = 0.94498289

Unit: Time-domain beamforming, prefs version 1
    beamforming enabled  = false
    0 degrees is Y-axis  = true
    beam angles          = 0:45:180
    plot beam angles     = 70
    plot beam freqs      = 500
    weighting enabled    = true

Unit: DCLInterface, prefs version 1
    enabled              = false
    dcl function search dir = 
    dcl function path to json = 
