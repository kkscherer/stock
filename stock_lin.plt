#!/gnuplot
#
#    
#    	G N U P L O T
#    	Version 4.2 patchlevel 2 
#    	last modified 31 Aug 2007
#    	System: MS-Windows 32 bit 
#    
#    	Copyright (C) 1986 - 1993, 1998, 2004, 2007
#    	Thomas Williams, Colin Kelley and many others
#    
#    	Type `help` to access the on-line reference manual.
#    	The gnuplot FAQ is available from http://www.gnuplot.info/faq/
#    
#    	Send bug reports and suggestions to <http://sourceforge.net/projects/gnuplot>
#    
# set terminal windows color noenhanced font "Arial, 10"
# set output
unset clip points
set clip one
unset clip two
set bar 1.000000
set border 31 front linetype -1 linewidth 1.000
set xdata time
set ydata
set zdata
set x2data
set y2data
#set timefmt x "%Y-%m-%d"
set timefmt x "%d-%b-%y"
set timefmt y "%Y-%m-%d"
set timefmt z "%Y-%m-%d"
set timefmt x2 "%Y-%m-%d"
set timefmt y2 "%Y-%m-%d"
set timefmt cb "%Y-%m-%d"
set boxwidth
set style fill  empty border
set style rectangle back fc  lt -3 fillstyle  solid 1.00 border -1
set dummy x,y
set format x "%d-%b-%y"
set format y "% g"
set format x2 "% g"
set format y2 "% g"
set format z "% g"
set format cb "% g"
set angles radians
set grid nopolar
set grid xtics nomxtics ytics nomytics noztics nomztics \
 nox2tics nomx2tics noy2tics nomy2tics nocbtics nomcbtics
set grid layerdefault   linetype 0 linewidth 1.000,  linetype 0 linewidth 1.000
load "title.plt"
set key inside right top vertical Right noreverse enhanced autotitles nobox
set key noinvert samplen 4 spacing 1 width 0 height 0 
unset label
unset arrow
set style increment default
unset style line
unset style arrow
set style histogram clustered gap 2 title  offset character 0, 0, 0
unset logscale
set offsets 0, 0, 0, 0
set pointsize 1
set encoding default
unset polar
unset parametric
unset decimalsign
set view 60, 30, 1, 1
set samples 100, 100
set isosamples 10, 10
set surface
unset contour
set clabel '%8.3g'
set mapping cartesian
set datafile separator whitespace
unset hidden3d
set cntrparam order 4
set cntrparam linear
set cntrparam levels auto 5
set cntrparam points 5
set size ratio 0 1,1
set origin 0,0
set style data points
set style function lines
set xzeroaxis linetype -2 linewidth 1.000
set yzeroaxis linetype -2 linewidth 1.000
set zzeroaxis linetype -2 linewidth 1.000
set x2zeroaxis linetype -2 linewidth 1.000
set y2zeroaxis linetype -2 linewidth 1.000
set ticslevel 0.5
set mxtics default
set mytics default
set mztics default
set mx2tics default
set my2tics default
set mcbtics default
set xtics border in scale 1,0.5 mirror norotate  offset character 0, 0, 0
set xtics autofreq 
set ytics border in scale 1,0.5 mirror norotate  offset character 0, 0, 0
set ytics autofreq 
set ztics border in scale 1,0.5 nomirror norotate  offset character 0, 0, 0
set ztics autofreq 
set nox2tics
set noy2tics
set cbtics border in scale 1,0.5 mirror norotate  offset character 0, 0, 0
set cbtics autofreq 
set title  offset character 0, 0, 0 font "" norotate
set timestamp bottom 
set timestamp "" 
set timestamp  offset character 0, 0, 0 font "" norotate
set rrange [ * : * ] noreverse nowriteback  # (currently [0.000000:10.0000] )
set trange [ * : * ] noreverse nowriteback  # (currently ["1999-12-31":"2000-01-01"] )
set urange [ * : * ] noreverse nowriteback  # (currently ["1999-12-31":"2000-01-01"] )
set vrange [ * : * ] noreverse nowriteback  # (currently ["1999-12-31":"2000-01-01"] )
set xlabel "Date" 
set xlabel  offset character 0, 1, 0 font "" textcolor lt -1 norotate
set x2label "" 
set x2label  offset character 0, 0, 0 font "" textcolor lt -1 norotate
set xrange [ * : * ] noreverse nowriteback  # (currently ["2000-01-01":"2000-01-01"] )
set x2range [ * : * ] noreverse nowriteback  # (currently [-10.0000:10.0000] )
set ylabel "$" 
set ylabel  offset character 0, 0, 0 font "" textcolor lt -1 rotate by 90
set y2label "" 
set y2label  offset character 0, 0, 0 font "" textcolor lt -1 rotate by 90
set yrange [ * : * ] noreverse nowriteback  # (currently [-500.000:500.000] )
set y2range [ * : * ] noreverse nowriteback  # (currently [-10.0000:10.0000] )
set zlabel "" 
set zlabel  offset character 0, 0, 0 font "" textcolor lt -1 norotate
set zrange [ * : * ] noreverse nowriteback  # (currently [-10.0000:10.0000] )
set cblabel "" 
set cblabel  offset character 0, 0, 0 font "" textcolor lt -1 norotate
set cbrange [ * : * ] noreverse nowriteback  # (currently [-10.0000:10.0000] )
set zero 1e-008
set lmargin -1
set bmargin -1
set rmargin -1
set tmargin -1
set locale "C"
set pm3d explicit at s
set pm3d scansautomatic
set pm3d interpolate 1,1 flush begin noftriangles nohidden3d corners2color mean
set palette positive nops_allcF maxcolors 0 gamma 1.5 color model RGB 
set palette rgbformulae 7, 5, 15
set colorbox default
set colorbox vertical origin screen 0.9, 0.2, 0 size screen 0.1, 0.63, 0 bdefault
set loadpath 
set fontpath 
set fit noerrorvariables
set zrange [ * : * ] noreverse nowriteback  # (currently [-10.0000:10.0000] )
set zero 1e-08
set lmargin -1
set bmargin -1
set rmargin -1
set tmargin -1
set locale "C"
set terminal win
plot 'table_lin.tsv' using 1:5:3:4 with yerrorbars , 'table_lin.tsv' using 1:9:10:8 with yerrorbars 3, 'table_lin.tsv' using 1:5 with lines 2 
#plot 'table_lin.tsv' using 0:5:3:4 with yerrorbars , 'table_lin.tsv' using 1:9 with lines 3, 'table_lin.tsv' using 1:8 with lines 3, 'table_lin.tsv' using 1:10 with lines 3, 'table_lin.tsv' using 1:5 with lines 2 
pause -1
plot 'table_lin.tsv' using 1:5:3:4 with yerrorbars , 'table_lin.tsv' using 1:9:10:8 with yerrorbars 3, 'table_lin.tsv' using 1:5 with lines 2, 'table_lin.tsv' using 1:7 with lines 3
pause -1
#    EOF
