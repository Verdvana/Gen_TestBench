#! /usr/bin/perl -w

## ============================================================================ ##
##                                                                              ##
## Module Name:					Gen_TestBench                                   ##
## Department:					Qualcomm (Shanghai) Co., Ltd.                   ##
## Function Description:	    TestBench生成器                                  ##
##                                                                              ##
## ---------------------------------------------------------------------------- ##
##                                                                              ##
## Version 	Design		Coding		Simulata	  Review		Rel data        ##
## V1.0		Verdvana	Verdvana	Verdvana		  			2021-08-07      ##
##                                                                              ##
## ---------------------------------------------------------------------------- ##
##                                                                              ##
## Version	Modified History                                                    ##
## V1.0		                                                                    ##
##                                                                              ##
##============================================================================= ##

use File::Glob;

print   '
@@O*=O[\`/@/,@/=@/\@@@@O\OO@/O@/\@@@O@@@@@@@@@@@@@@\/@@`]/O@@/O@o\.OO`O@O[
,O..[`.,O@^,O/@/,O]],\@/`,O^=@OO@@@@@@@@@@@@@@@@@@@@@@@@O`[@@OO@/.O@O.,O.[
]]O.O@`.\@^.OO/O.=@@]]=@@OO@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@O/OOOO`,.[*]..@
...,O]`..,@^,@O@@@@@@OO@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@Oo\/@@O@O`,
=O`,[.,O*O.,[`..\OO@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@^..=@
]OO`/O,O/,o[O@O\O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@`]]OO\
O@O,O`=@`....OO@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@`,@/=
.[.O\/@O/,@`=@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@[\]
]` .[`O^...O@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@^.`
O^.,[\]/OO/@@@@@@@@@@@@@@@@@@@@@@@OO@@O[[[`.[[[[[[OO@@@@@@@@@@@@@@@@@@@@.,
.OO`,[\OOO@@@@@@@@@@@@@@@OO[[....,/O`...................,[@@@@@@@@@@@@@@@O
]]]O@OO],O@@@@@@@@@@@@/.......]OO`.]/OOO\]]................,@@`,\@@@@@@@@O
..O`*.]O@@@@@@@@@@@@@@`..]]O@/./@O[`..   .[@@\............]].=@O`..\@@@@@O
 ./\.\`/O@@@@@@@@@@@@^ .[[`.,@O`            ,O@\....,O@O[[.[[O@@@@`.,@@@@O
O`,` ,^./@@@@@@@@@@@/.....,@/.               .@@^.,@[.        .\@@@OO@@/./
......,@O`....\@@@@O.....=@/           .....  =@OOO.            ,@@@@@/...
...../@^...]`...O@@OOOO@@@O.          ...,[O@@@@@@@O]]].         \@@@O....
....=@O.....O@...O^.....=@^                =@OO@@/.O@/`[[.       =@@@O....
....=@^..../@@^.........O@.                  .O@@^ ..           .O@@@@^...
....O@^...=O[@^.........O@`                  ,@@@^              =@@/.@O...
....O@^...,OOO..........=@\                 .O@O@\             .O@/.=@^...
....=@O.....,............=@\.              ./@^.O@`            =@O.,@/....
.....O@\...................O@`            ,O@^.,/@@\.         /@@O]@/.....
......O@@`...................[OO]].,]]]]O@/` ,/[`.,O@O].  .,/@/\@@/.......
........\@@@OOO\.............................\....,O/.,[[[[`...=@@........
............. =@\.............................[OO/[............=@O........
.............. ,@@`...........................................=@@^........
.........]/OOO@OO@@@]........................................,@@^.........
......,O/.......[@@OO@@]....................................,@@`..........
....,@/...........,@@`.[@@\]/OOO/[[[[\OO]................../@O............
...=@`..............\@O]]/@@@O]..........\@\............./@@`.............
..,@^............./O[........,[O@O]`...... ,O`......]/O@@/`...............
..O/............,O^..............\@@/\OO@@@OO@@@@@@O[`.\@`................
.=@^............@^....,/O/[`......=@@]]]` .O@^..........@O................
.=@^...........=@^ ,OO`............\@O..\@`=@O..........\@^...............
..@\............,@@/......]OO[......O@^...\@@@`.........=@^...............
..O@^............=O...,OO[..........=@O.]OO[[O@@\........OO...............

##########################################################################
##################          Generate TestBench          ##################
##########################################################################
';

my $File_Name       = "";
my $Module_Name     = "";
my $Timescale       = "";
my $timeunit        = "";
my $timeprecision   = "";
my $Include         = "";
my $Define          = "";
my $Parameter       = "";
my $Interface       = "";


my $Remark_flag   = 0;
my $Param_flag   = 0;
my $Intf_flag   = 0;





################################################################
# HDL文件处理
unlink (<*_TB.sv>);
while (<*.sv>){
    $File_Name = $_;
}

if($File_Name eq ""){
    while (<*.v>){
        $File_Name = $_;
    }
}

unlink ("PREPROCESSED_FILE.sv");    # 预防性删除
open(HDL_FILE, $File_Name) || die "Cannot open HDL file\n";
open PREPROCESSED_FILE, '>>'."PREPROCESSED_FILE.sv";

while(<HDL_FILE>){
    $_ =~ s/\/\/.*//;           # 去掉双斜杠的注释
    if($_ =~ /\/\*/){           # 去掉/**/注释
        $Remark_flag = 1;
        $_ =~ s/\/\*.*//;
    }
    elsif($Remark_flag == 1){
        if($_ =~ /\*\//){
            $Remark_flag = 0;
            $_ =~ s/^.*\*\///;
        }
        else{
            $_ =~ s/.*//;
        }
    }

    $_ =~ s/\v*$/\n/;               # 有的编译器换行符是“\v”，因此要替换成“\n”
    while($_ =~ s/(([ ]|\t)\n)$/\n/){}
    $_ =~ s/^\n*//;

    #$_ =~ s/^\s*//;             # 去掉空行和每行前面的空白
    $_ =~ s/(\s+\;)/;/;         # 去掉分号前的空格
    $_ =~ s/(\s+\,)/,/;         # 去掉逗号前的空格
    print PREPROCESSED_FILE;
}
close(HDL_FILE);
close(PREPROCESSED_FILE);


open(PREPROCESSED_FILE, "PREPROCESSED_FILE.sv") || die "Cannot open HDL file\n";
while(<PREPROCESSED_FILE>){
    if($_ =~ /\`timescale/){
        $Timescale = $_;
    }
    elsif($_ =~ /timeunit/){
        $timeunit = $_;
    }
    elsif($_ =~ /timeprecision/){
        $timeprecision = $_;
    }
    elsif($_ =~ /`include/){
        $Include .= $_;
    }
    elsif($_ =~ /`define/){
        $Define .= $_;
    }
    elsif($_ =~ /module /){
        $Module_Name = $';
        $Module_Name =~ s/\#||\(||\s//g;
        if($_ =~ s/^.*\#//){
            $_ =~ s/^\s*//;     # 去掉空格
            $_ =~ s/^\(//;      # 去掉括号
            $Parameter  = $_;
            $Param_flag = 1;
        }
        elsif($_ =~ s/^.*\(//){
            $Intf_flag  = 1;
        }
    }
    elsif($_ =~ /parameter/){
        $Parameter  .= $_;
        $Param_flag = 1;
    }
    elsif($Param_flag == 1){
        if($_ =~ /\)(([ ]*\()|\n)/g){   # 判断parameter是否结束
            $Parameter  .= $_;
            $Param_flag = 0;
            $Intf_flag  = 1;
        }
        else{
            $Parameter .= $_;
        }
    }
    elsif($_ =~ /^\(/){
        $Intf_flag  = 1;
        $Interface .= $_;
    }
    elsif($Intf_flag == 1){
        if($_ =~ /\)\;/){
            $Intf_flag   = 0;
            $Interface .= $_;
            last;
        }
        else{
            $Interface .= $_;
        }
    }
}

close(PREPROCESSED_FILE);
unlink ("PREPROCESSED_FILE.sv");


$Parameter =~ s/^(\(|\n)//;     #去掉开头可能存在的“(”
$Parameter =~ s/(\)[ ]*\()$//;  #去掉结尾可能存在的“)   (”
$Parameter =~ s/\n$//;          #去掉结尾可能存在的换行符
$Parameter =~ s/\v*$//;         #去掉结尾可能存在的换行符
$Parameter =~ s/\)$//;          #去掉结尾可能存在的“)”
$Parameter =~ s/\v*$//;         #去掉结尾可能存在的换行符
$Parameter =~ s/[ ]*$//;        #去掉结尾可能存在的空格


$Interface =~ s/^[ ]*//;        #去掉开头可能存在的空格
$Interface =~ s/^(\(|\n)//;     #去掉开头可能存在的“(”
$Interface =~ s/^\n//;          #去掉开头可能存在的换行符
$Interface =~ s/(\)\;)//;       #去掉结尾存在的“);”
$Interface =~ s/\n*$//;         #去掉结尾可能存在的换行符
$Interface =~ s/\v*$//;         #去掉结尾可能存在的换行符
$Interface .= "\n";


$TB_Name = $Module_Name."_TB";
=pod
print "Module Name:\n$Module_Name\n";
print "Timescale:\n$Timescale\n";
print "timeunit:\n$timeunit\n";
print "timeprecision:\n$timeprecision\n";
print "Include:\n$Include\n";
print "Define:\n$Define\n";
print "Parameter:\n$Parameter\n";
print "Interface:\n$Interface\n";
=cut


print "
##################   HDL file processed successfully    ##################

";



####################################################################
# Process interface
my $Num_Clk = 0;
my $Num_rst = 0;
my $Num_Input = 0;
my $Num_Output = 0;
my @Clock;
my @Reset;
my @Input;
while($Interface =~ /(input|output)(.*?)((\,)|(\n))/gs){
    if($1 eq "input"){
        $tmp1 = $2;
        if($tmp1 =~ /(\w+)$/){
            if(!($tmp1 =~ /clk|clock|rst|reset/)){
                push @Input, $1;
                $Num_Input++;
            }
        }
    }
    elsif($1 eq "output"){
        $Num_Output++;
    }
    push @Inout, $2;
}

for(@Inout){
    $_ =~ s/logic|wire|reg//;
    $Signal .= "    logic $_;\n";
    $_ =~ s/\s//gs;
    if($_ =~ /clk|clock/i){
        $Num_Clk++;
        push @Clock, $_;
    }
    elsif($_ =~ /rst|reset/i){
        $Num_rst++;
        push @Reset, $_;
    }
}

####################################################################
# Input

for($i=0;$i<$Num_Clk;$i++){
    print "Clock $i Frequency(Hz):";
    $Clock_Freq = <STDIN>;
    chomp($Clock_Freq);
    if($Clock_Freq =~ /\d+/){}
    else{
        die "Syntax Error\n";
    }
    push @Clk_Freq ,$Clock_Freq;
}

$gcd  = 1;
for($i=0;$i<$Num_Clk;$i++){
    $Period = int (10000000000/$Clk_Freq[$i]);
    push @Period ,$Period;
    $gcd = &GCD($gcd,$Period); 
}



print "TIN(ns):";
$TIN = <STDIN>;
chomp($TIN);

if($TIN =~ /\d+/){}
else{
    die "Syntax Error\n";
}

####################################################################
# Clock drive and task
$Clock_Drive = "
    //=========================================================
    // Clock drive"; 
for($i=0;$i<$Num_Clk;$i++){
    $Clock_Drive .= "
    initial begin
        ${Clock[$i]} = '0;
        forever #(PERIOD_$i/2) ${Clock[$i]} = ~${Clock[$i]};
    end
"
}

$Task_Reset = "
    //=========================================================
    // Task reset
    task task_rst;";
for($i=0;$i<$Num_rst;$i++){
    if(${Reset[$i]} =~ /\_n/s){
        $Task_Reset .= "
        ${Reset[$i]}    = '0;"
    }
    else{
        $Task_Reset .= "
        ${Reset[$i]}    = '1;"
    }
}      
$Task_Reset .= "

        #$gcd;
"; 
for($i=0;$i<$Num_rst;$i++){
    if(${Reset[$i]} =~ /n/s){
        $Task_Reset .= "
        ${Reset[$i]}    = '1;"
    }
    else{
        
        $Task_Reset .= "
        ${Reset[$i]}    = '0;"
    }
}
$Task_Reset .= "
    endtask
";

$Task_Init = "
    //=========================================================
    // Task init
    task task_init;";
for($i=0;$i<$Num_Input;$i++){
    $Task_Init .= "
        ${Input[$i]}    = '0;"
}
$Task_Init .= "
        #TIN;
    endtask
";

####################################################################
# Instantiate
my @Parameter;
my $Num_Param = 0;
while($Parameter =~ /(.*?)(\w+)(\s+)(\=)(.*?)/g){
    push @Parameter, $2;
    $Num_Param++;
}

if($Num_Param == 0){
    $Instantiate = "
    //=========================================================
    // Instantiate
    $Module_Name u_$Module_Name(
        .*
    );
"
}
else{
    $Instantiate = "
    //=========================================================
    // Instantiate
    $Module_Name #(";
    for($i=0;$i<$Num_Param;$i++){
        $Instantiate .= "
        .${Parameter[$i]}(${Parameter[$i]}),"
    }
    $Instantiate =~ s/\,$//;
    $Instantiate .="
    ) u_$Module_Name(
        .*
    );
"
}

####################################################################
# Parameter
if($Num_Param == 0){}
else{
    $Parameter .= ";"
}

####################################################################
# Parameter_TB
$Parameter_TB = "
    parameter       TIN     = $TIN,";
for($i=0;$i<$Num_Clk;$i++){
    $Parameter_TB .= "
                    PERIOD_$i   = $Period[$i],"; 
}
$Parameter_TB  =~ s/\,$/;/;


####################################################################
# Get time 

## use POSIX qw(strftime);
## $datestring = strftime "%Y-%m-%d", localtime;
my ($sec ,$min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
$mon=(sprintf "%02d", ($mon+1));
$mday=(sprintf "%02d", $mday);


########################################
# Generate file

open TB_FILE, '>'."$TB_Name.sv";

print TB_FILE
"//=============================================================================
//
// Module Name:					$TB_Name
// Department:					Qualcomm (Shanghai) Co., Ltd.
// Function Description:	    $Module_Name TestBench
//
//------------------------------------------------------------------------------
//
// Version 	Design		Coding		Simulata	  Review		Rel data
// V1.0		Verdvana	Verdvana	Verdvana		  			".($year+1900)."-${mon}-${mday}
//
//------------------------------------------------------------------------------
//
// Version	Modified History
// V1.0		$Module_Name Test
//
//=============================================================================

//=========================================================
// The time unit and precision of the external declaration
$Timescale$timeunit$timeprecision
//=========================================================
// Include
$Include
//=========================================================
// Define
$Define
//=========================================================
// Module
module $TB_Name;

    //=========================================================
    //Parameter
$Parameter
$Parameter_TB

    //=========================================================
    // Signal
$Signal
$Instantiate
$Clock_Drive
$Task_Reset
$Task_Init

    //=========================================================
    // Simulation
    initial begin
        //Reset&Init
        task_rst;
        task_init;

        // Simulation behavior



        #400;
        \$finish;
    end

endmodule
";

close(TB_FILE);


########################################
# 求最小公倍数
sub GCD{
    my($a,$b)=@_;
    my $c;
    my $m;
    my $t;
    if($a<$b){
        $t=$a;
        $a=$b;
        $b=$t;
    }
    $m=$a * $b;
    $c=$a % $b;
    
    while($c!=0){
        $a= $b;
        $b= $c;
        $c= $a % $b;
    }

    return $m; 
}