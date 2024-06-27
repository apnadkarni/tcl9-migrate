##############################################################################
# This is the generic definitions needed for Snit.
##############################################################################

##nagelfar syntax _stdclass_snit s x*
##nagelfar subcmd _stdclass_snit destroy configurelist configure
##nagelfar syntax _stdclass_snit\ destroy 0
##nagelfar syntax _stdclass_snit\ configurelist x
##nagelfar syntax _stdclass_snit\ configure p*

##nagelfar syntax snit::type do=_stdclass_snit cn
##nagelfar syntax snit::type::method dm
##nagelfar syntax snit::type::constructor cv
##nagelfar syntax snit::type::destructor cl
##nagelfar syntax snit::type::option x x*
##nagelfar syntax snit::type::component x
##nagelfar syntax snit::type::delegate x*
##nagelfar syntax snit::type::install s x*
##nagelfar syntax snit::type::mymethod x x*
##nagelfar return snit::type::mymethod script
##nagelfar syntax snit::type::myvar l
##nagelfar return snit::type::myvar varName

##nagelfar syntax snit::widgetadaptor do=_stdclass_snit cn
##nagelfar syntax snit::widgetadaptor::method dm
##nagelfar syntax snit::widgetadaptor::constructor cv
##nagelfar syntax snit::widgetadaptor::destructor cl
##nagelfar syntax snit::widgetadaptor::delegate x*
##nagelfar syntax snit::widgetadaptor::installhull x*
##nagelfar syntax snit::widgetadaptor::from l x*
##nagelfar syntax snit::widgetadaptor::mymethod x x*
##nagelfar return snit::widgetadaptor::mymethod script
##nagelfar syntax snit::widgetadaptor::myvar l
##nagelfar return snit::widgetadaptor::myvar varName
##nagelfar syntax snit::widgetadaptor::component x
##nagelfar syntax snit::widgetadaptor::install s x*
##nagelfar syntax snit::widgetadaptor::option 1: x 2: x x : x p*
##nagelfar syntax snit::widgetadaptor::onconfigure x cv

##nagelfar syntax snit::widget do=_stdclass_snit cn
##nagelfar syntax snit::widget::method dm
##nagelfar syntax snit::widget::constructor cv
##nagelfar syntax snit::widget::destructor cl
##nagelfar syntax snit::widget::delegate x*
##nagelfar syntax snit::widget::installhull x*
##nagelfar syntax snit::widget::from l x*
##nagelfar syntax snit::widget::hulltype x
##nagelfar syntax snit::widget::widgetclass x
##nagelfar syntax snit::widget::mymethod x x*
##nagelfar return snit::widget::mymethod script
##nagelfar syntax snit::widget::myvar l
##nagelfar return snit::widget::myvar varName
##nagelfar syntax snit::widget::component x
##nagelfar syntax snit::widget::install s x*
##nagelfar syntax snit::widget::option x p*

##nagelfar package known snit
