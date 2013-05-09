#!/bin/tcsh
#===============================================================================
#+
# NAME:
#   SWAPSHOP
#
# PURPOSE:
#   Run SWAP.py multiple times on a database, until all classifications
#   are in - and then collate outputs for use by SWITCH etc.
#
# COMMENTS:
#
# INPUTS:
#
# OPTIONAL INPUTS:
#   -h --help         Print this header
#   -f --startup      Start afresh. Def = continue from update.config
#   -s --survey name  Survey name (used in prefix of everything)
#   -t --test N       Only run SWAP.py N times
#
# OUTPUTS:
#
# EXAMPLES:
#
#   SWAPSHOP.csh
#
# BUGS:
#
# REVISION HISTORY:
#   2013-05-09  started: Marshall (Oxford)
#-
# ==============================================================================

set help = 0
set survey = 'CFHTLS'
set N = 'infinity'
set startup = 0

while ( $#argv > 0 )
   switch ($argv[1])
   case -h:        
      shift argv
      set help = 1
      breaksw
   case --{help}:        
      shift argv
      set help = 1
      breaksw
   case -f:        
      shift argv
      set startup = 1
      breaksw
   case --{startup}:        
      shift argv
      set startup = 1
      breaksw
   case -s:        
      shift argv
      set survey = $argv[1]
      shift argv
      breaksw
   case --{survey}:        
      shift argv
      set survey = $argv[1]
      shift argv
      breaksw
   case -t:        
      shift argv
      set N = $argv[1]
      shift argv
      breaksw
   case --{test}:        
      shift argv
      set N = $argv[1]
      shift argv
      breaksw
   case *:        
      set dbfile = $argv[1]
      shift argv
      breaksw
   endsw
end

if ($help) then
  more $0
  goto FINISH
endif

# ----------------------------------------------------------------------

echo '================================================================================'
echo '                    SWAPSHOP: Space Warps Analysis Blitz                        '
echo '================================================================================'

echo "SWAPSHOP: running SWAP.py over and over again until all"
echo "SWAPSHOP: classifications in survey '$survey' are analysed"

# ----------------------------------------------------------------------

# First write a startup.config file based on the standard one in swap:

if ($startup) then
    set configfile = startup.config
    cat $SWAP_DIR/swap/$configfile | sed s/SURVEY/$survey/g > $configfile
    echo "SWAPSHOP: start-up configuration stored in $configfile"
else
    set configfile = 'update.config'
    if (! -e $configfile) then
        echo "SWAPSHOP: ERROR: no update.config file to start from."
        goto FINISH
    endif
    echo "SWAPSHOP: continuing using configuration stored in $configfile"
endif

# ----------------------------------------------------------------------

# Assume we are in the right place, and just get going:

set more_to_do = 1
set k = 0

while ($more_to_do)
    
    # Stop early if we are just testing:
    if ($k == $N) then
        
        echo 'stopped' > .swap.cookie
    
    else
        # Run SWAP again:
        @ kk = $k + 1
        echo "SWAPSHOP: starting batch number $kk"
        
        SWAP.py  $configfile
    
        # Keep a record of the config we used in this run...
        # That means replacing the new start time in update.config
        # with the actual start time of the latest run:

        set latest = `\ls -dtr ${survey}_????-??-??_??:??:?? | tail -1`
        set now = `echo $latest | sed s/$survey//g | cut -c2-50`
        
        set tomorrow = `grep 'start:' $configfile | cut -d':' -f2-20`
        sed s/$tomorrow/$now/g $configfile > $latest/update.config
        
    endif     
    
    @ k = $k + 1
    
    # See if we should keep going:
    set more_to_do = `grep 'running' .swap.cookie | wc -l`
    if ($more_to_do) set configfile = update.config
    
    
end

# Great: we should now have everything we need, in a whole bunch of 
# directories.

# ----------------------------------------------------------------------

# Collate outputs in various ways:

set latest = `\ls -dtr ${survey}_????-??-??_??:??:?? | tail -1`
set today = $cwd:t

# - - - - - - - - - - 
# 1) Retirement plan:

set retirees = ${survey}_${today}_retire_these.txt
cp $latest/*retire_these.txt  $retirees

set NR = `cat $retirees | wc -l`

if ($NR > 0) then
    echo "SWAPSHOP: if you want, you can go ahead and retire $NR subjects with"
    echo " "
    echo "          SWITCH.py $retirees"
    echo " "
else
    echo "SWAPSHOP: no subjects to retire"
endif

# - - - - - - - - - -
# 2) Final report:

set report = ${survey}_${today}_report.pdf
cp $latest/*report.pdf  $report

echo "SWAPSHOP: final report: $report"

# - - - - - - - - - -
# 3) Animated plots:

echo "SWAPSHOP: you can view some animated plots on your browser with (wait for it):"
echo " "

foreach type ( trajectories histories probabilities )

    set gif = $cwd/${survey}_${today}_${type}.gif

    convert -delay 50 -loop 0 ${survey}_*/*${type}.png $gif

    echo "          file://$gif"
    echo " "

end

# - - - - - - - - - -
# 4) Image download:

foreach type ( candidates \
               training_false_negatives \
               training_false_positives )
    mkdir -p $type
    chdir $type
    echo "SWAPSHOP: in folder '$type',"
    
    set catalog = `\ls ../*${type}*txt`
    set N = `cat $catalog | wc -l`
    echo "SWAPSHOP: downloading $N images..."
    
    foreach url ( `cat $catalog` )
        set png = $url:t
        set log = $png:r.log
        wget -O $png "$url" >& $log
    end
    
    chdir ..
    echo "SWAPSHOP: ...done."
    
end
    
echo "SWAPSHOP: all done."

echo '================================================================================'

# ==============================================================================
FINISH:
