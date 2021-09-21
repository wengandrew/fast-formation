%%
clc
clear
close all
warning('off')

n = 1; % 1 : continous cycling data , 2 : OCV charging data




BL_fn.Cell01 = {'UM01_Test007_CA1.txt','UM01_Test020_CA1.txt','UM01_Test032_CA1.txt','UM01_Test050_CA1.txt','UM01_Test068_CA1.txt','UM01_Test086_CA1.txt','UM01_Test107_CA1.txt','UM01_Test128_CA1.txt','UM01_Test148_CA1.txt'};
BL_fn.Cell02 = {'UM02_Test008_CA2.txt','UM02_Test021_CA2.txt','UM02_Test033_CA2.txt','UM02_Test051_CA2.txt','UM02_Test069_CA2.txt','UM02_Test087_CA2.txt','UM02_Test108_CA2.txt','UM02_Test129_CA2.txt','UM02_Test149_CA2.txt'};
BL_fn.Cell03 = {'UM03_Test009_CA3.txt','UM03_Test022_CA3.txt','UM03_Test034_CA3.txt','UM03_Test052_CA3.txt','UM03_Test070_CA3.txt','UM03_Test088_CA3.txt'};
BL_fn.Cell04 = {'UM04_Test010_CA4.txt','UM04_Test023_CA4.txt','UM04_Test035_CA4.txt','UM04_Test053_CA4.txt','UM04_Test071_CA4.txt','UM04_Test089_CA4.txt','UM04_Test110_CA4.txt','UM04_Test131_CA4.txt','UM04_Test151_CA4.txt'};
BL_fn.Cell05 = {'UM05_Test011_CA5.txt','UM05_Test024_CA5.txt','UM05_Test036_CA5.txt','UM05_Test054_CA5.txt','UM05_Test072_CA5.txt','UM05_Test090_CA5.txt','UM05_Test111_CA5.txt','UM05_Test132_CA5.txt','UM05_Test152_CA5.txt'};
BL_fn.Cell06 = {'UM06_Test012_CA6.txt','UM06_Test025_CA6.txt','UM06_Test037_CA6.txt','UM06_Test055_CA6.txt','UM06_Test073_CA6.txt','UM06_Test091_CA6.txt','UM06_Test112_CA6.txt','UM06_Test133_CA6.txt','UM06_Test153_CA6.txt'};
BL_fn.Cell07 = {'UM07_Test014_CA7.txt','UM07_Test026_CA7.txt','UM07_Test038_CA7.txt','UM07_Test056_CA7.txt','UM07_Test074_CA7.txt','UM07_Test092_CA7.txt'};
BL_fn.Cell09 = {'UM09_Test109_CA3.txt'};
BL_fn.Cell10 = {'UM10_Test113_CA7.txt'};
BL_fn.Cell12 = {'UM12_Test130_CA3.txt'};
BL_fn.Cell13 = {'UM13_Test134_CA7.txt'};
BL_fn.Cell15 = {'UM15_Test150_CA3.txt'};
BL_fn.Cell16 = {'UM16_Test154_CA7.txt'};
BL_fn.Cell17 = {'UM17_Test170_CA1.txt','UM17_Test182_CA1.txt','UM17_Test196_CA1.txt','UM17_Test209_CA1.txt','UM17_Test222_CA1.txt','UM17_Test235_CA1.txt','UM17_Test248_CA1.txt','UM17_Test261_CA1.txt','UM17_Test274_CA1.txt','UM17_Test287_CA1.txt','UM17_Test300_CA1.txt','UM17_Test313_CA1.txt','UM17_Test326_CA1.txt'};
BL_fn.Cell18 = {'UM18_Test171_CA2.txt','UM18_Test183_CA2.txt','UM18_Test197_CA2.txt','UM18_Test210_CA2.txt','UM18_Test223_CA2.txt','UM18_Test236_CA2.txt','UM18_Test249_CA2.txt','UM18_Test262_CA2.txt','UM18_Test275_CA2.txt','UM18_Test288_CA2.txt','UM18_Test301_CA2.txt','UM18_Test314_CA2.txt','UM18_Test327_CA2.txt'};
BL_fn.Cell19 = {'UM19_Test172_CA3.txt','UM19_Test184_CA3.txt','UM19_Test198_CA3.txt','UM19_Test211_CA3.txt','UM19_Test224_CA3.txt','UM19_Test237_CA3.txt','UM19_Test250_CA3.txt','UM19_Test263_CA3.txt','UM19_Test276_CA3.txt','UM19_Test289_CA3.txt','UM19_Test302_CA3.txt','UM19_Test315_CA3.txt','UM19_Test328_CA3.txt'};
BL_fn.Cell20 = {'UM20_Test173_CA4.txt','UM20_Test185_CA4.txt','UM20_Test199_CA4.txt','UM20_Test212_CA4.txt','UM20_Test225_CA4.txt','UM20_Test238_CA4.txt','UM20_Test251_CA4.txt','UM20_Test264_CA4.txt','UM20_Test277_CA4.txt','UM20_Test290_CA4.txt','UM20_Test303_CA4.txt','UM20_Test316_CA4.txt','UM20_Test329_CA4.txt'};
BL_fn.Cell21 = {'UM21_Test174_CA5.txt','UM21_Test186_CA5.txt','UM21_Test200_CA5.txt','UM21_Test213_CA5.txt','UM21_Test226_CA5.txt','UM21_Test239_CA5.txt','UM21_Test252_CA5.txt','UM21_Test265_CA5.txt','UM21_Test278_CA5.txt','UM21_Test291_CA5.txt','UM21_Test304_CA5.txt','UM21_Test317_CA5.txt','UM21_Test330_CA5.txt'};
BL_fn.Cell22 = {'UM22_Test175_CA6.txt','UM22_Test187_CA6.txt','UM22_Test201_CA6.txt','UM22_Test214_CA6.txt','UM22_Test227_CA6.txt','UM22_Test240_CA6.txt','UM22_Test253_CA6.txt','UM22_Test266_CA6.txt','UM22_Test279_CA6.txt','UM22_Test292_CA6.txt','UM22_Test305_CA6.txt','UM22_Test318_CA6.txt','UM22_Test331_CA6.txt'};
BL_fn.Cell23 = {'UM23_Test176_CA7.txt','UM23_Test188_CA7.txt','UM23_Test202_CA7.txt','UM23_Test215_CA7.txt','UM23_Test228_CA7.txt','UM23_Test241_CA7.txt','UM23_Test254_CA7.txt','UM23_Test267_CA7.txt','UM23_Test280_CA7.txt','UM23_Test293_CA7.txt','UM23_Test306_CA7.txt','UM23_Test319_CA7.txt','UM23_Test332_CA7.txt'};

BL_fn.Cell27 = {'UM27_Test355_CA1.txt','UM27_Test365_CA1.txt','UM27_Test375_CA1.txt','UM27_Test385_CA1.txt','UM27_Test395_CA1.txt','UM27_Test405_CA1.txt','UM27_Test415_CA1.txt','UM27_Test425_CA1.txt','UM27_Test435_CA1.txt','UM27_Test445_CA1.txt'};
BL_fn.Cell28 = {'UM28_Test356_CA2.txt','UM28_Test366_CA2.txt','UM28_Test376_CA2.txt','UM28_Test386_CA2.txt','UM28_Test396_CA2.txt','UM28_Test406_CA2.txt','UM28_Test416_CA2.txt','UM28_Test426_CA2.txt','UM28_Test436_CA2.txt','UM28_Test446_CA2.txt','UM28_Test456_CA2.txt'};
BL_fn.Cell29 = {'UM29_Test357_CA3.txt','UM29_Test367_CA3.txt','UM29_Test377_CA3.txt','UM29_Test387_CA3.txt','UM29_Test397_CA3.txt','UM29_Test407_CA3.txt','UM29_Test417_CA3.txt','UM29_Test427_CA3.txt'};
BL_fn.Cell30 = {'UM30_Test358_CA4.txt','UM30_Test368_CA4.txt','UM30_Test378_CA4.txt','UM30_Test388_CA4.txt','UM30_Test398_CA4.txt','UM30_Test408_CA4.txt','UM30_Test418_CA4.txt','UM30_Test428_CA4.txt','UM30_Test438_CA4.txt','UM30_Test448_CA4.txt','UM30_Test458_CA4.txt','UM30_Test468_CA4.txt'};%,'UM30_Test478_CA4.txt'};
BL_fn.Cell31 = {'UM31_Test359_CA5.txt','UM31_Test369_CA5.txt','UM31_Test379_CA5.txt','UM31_Test389_CA5.txt','UM31_Test399_CA5.txt','UM31_Test409_CA5.txt','UM31_Test419_CA5.txt','UM31_Test429_CA5.txt','UM31_Test439_CA5.txt','UM31_Test449_CA5.txt','UM31_Test459_CA5.txt','UM31_Test469_CA5.txt','UM31_Test479_CA5.txt'};
BL_fn.Cell32 = {'UM32_Test360_CA6.txt','UM32_Test370_CA6.txt','UM32_Test380_CA6.txt','UM32_Test390_CA6.txt','UM32_Test400_CA6.txt','UM32_Test410_CA6.txt','UM32_Test420_CA6.txt','UM32_Test430_CA6.txt','UM32_Test440_CA6.txt','UM32_Test450_CA6.txt','UM32_Test460_CA6.txt'};
BL_fn.Cell33 = {'UM33_Test361_CA7.txt','UM33_Test371_CA7.txt','UM33_Test381_CA7.txt','UM33_Test391_CA7.txt','UM33_Test401_CA7.txt','UM33_Test411_CA7.txt'};


BL_fn.Cell37 = {'UM37_Test425_CA7.txt'};
BL_fn.Cell38 = {'UM38_Test425_CA3.txt','UM38_Test425_c_CA3.txt','UM38_Test425_c2_CA3.txt'};
BL_fn.Cell40 = {'UM40_Test425_CA7.txt'};

BL_Rs_fn.Cell01 = {'UM01_Test005_CA1.txt','UM01_Test018_CA1.txt','UM01_Test030_2nd_CA1.txt','UM01_Test042_CA1.txt','UM01_Test060_CA1.txt','UM01_Test078_CA1.txt','UM01_Test096_CA1.txt','UM01_Test117_CA1.txt','UM01_Test138_CA1.txt','UM01_Test158_CA1.txt'};
BL_Rs_fn.Cell02 = {'UM02_Test005_CA2.txt','UM02_Test018_CA2.txt','UM02_Test030_2nd_CA2.txt','UM02_Test043_CA2.txt','UM02_Test061_CA2.txt','UM02_Test079_CA2.txt','UM02_Test097_CA2.txt','UM02_Test118_CA2.txt','UM02_Test139_CA2.txt','UM02_Test159_CA2.txt'};
BL_Rs_fn.Cell03 = {'UM03_Test005_CA3.txt','UM03_Test018_CA3.txt','UM03_Test030_2nd_CA3.txt','UM03_Test044_CA3.txt','UM03_Test062_CA3.txt','UM03_Test080_CA3.txt','UM03_Test098_CA3.txt'};
BL_Rs_fn.Cell04 = {'UM04_Test005_CA4.txt','UM04_Test018_CA4.txt','UM04_Test030_2nd_CA4.txt','UM04_Test045_CA4.txt','UM04_Test063_CA4.txt','UM04_Test081_CA4.txt','UM04_Test099_CA4.txt','UM04_Test120_CA4.txt','UM04_Test141_CA4.txt','UM04_Test161_CA4.txt'};
BL_Rs_fn.Cell05 = {'UM05_Test005_CA5.txt','UM05_Test018_CA5.txt','UM05_Test030_2nd_CA5.txt','UM05_Test046_CA5.txt','UM05_Test064_CA5.txt','UM05_Test082_CA5.txt','UM05_Test100_CA5.txt','UM05_Test121_CA5.txt','UM05_Test142_CA5.txt','UM05_Test162_CA5.txt'};
BL_Rs_fn.Cell06 = {'UM06_Test005_CA6.txt','UM06_Test018_CA6.txt','UM06_Test030_2nd_CA6.txt','UM06_Test047_CA6.txt','UM06_Test065_CA6.txt','UM06_Test083_CA6.txt','UM06_Test101_CA6.txt','UM06_Test122_CA6.txt','UM06_Test143_CA6.txt','UM06_Test163_CA6.txt'};
BL_Rs_fn.Cell07 = {'UM07_Test005_CA7.txt','UM07_Test018_CA7.txt','UM07_Test030_2nd_CA7.txt','UM07_Test048_CA7.txt','UM07_Test066_CA7.txt','UM07_Test084_CA7.txt','UM07_Test102_CA7.txt'};
BL_Rs_fn.Cell09 = {'UM09_Test105_CA3.txt','UM09_Test119_CA3.txt'};
BL_Rs_fn.Cell10 = {'UM10_Test105_CA7.txt','UM10_Test123_CA7.txt'};
BL_Rs_fn.Cell12 = {'UM12_Test126_CA3.txt','UM12_Test140_CA3.txt'};
BL_Rs_fn.Cell13 = {'UM13_Test126_CA7.txt','UM13_Test144_CA7.txt'};
BL_Rs_fn.Cell15 = {'UM13_Test126_CA7.txt','UM15_Test160_CA3.txt'};
BL_Rs_fn.Cell16 = {'UM13_Test126_CA7.txt','UM16_Test164_CA7.txt'};
BL_Rs_fn.Cell17 = {'UM17_Test167_CA1.txt','UM17_Test180_CA1.txt','UM17_Test194_CA1.txt','UM17_Test206_CA1.txt','UM17_Test220_CA1.txt','UM17_Test233_CA1.txt','UM17_Test246_CA1.txt','UM17_Test259_CA1.txt','UM17_Test272_CA1.txt','UM17_Test285_CA1.txt','UM17_Test298_CA1.txt','UM17_Test311_CA1.txt','UM17_Test324_CA1.txt','UM17_Test337_CA1.txt'};
BL_Rs_fn.Cell18 = {'UM18_Test167_CA2.txt','UM18_Test180_CA2.txt','UM18_Test194_CA2.txt','UM18_Test206_CA2.txt','UM18_Test220_CA2.txt','UM18_Test233_CA2.txt','UM18_Test246_CA2.txt','UM18_Test259_CA2.txt','UM18_Test272_CA2.txt','UM18_Test285_CA2.txt','UM18_Test298_CA2.txt','UM18_Test311_CA2.txt','UM18_Test324_CA2.txt','UM18_Test337_CA2.txt'};
BL_Rs_fn.Cell19 = {'UM19_Test167_CA3.txt','UM19_Test180_CA3.txt','UM19_Test194_CA3.txt','UM19_Test206_CA3.txt','UM19_Test220_CA3.txt','UM19_Test233_CA3.txt','UM19_Test246_CA3.txt','UM19_Test259_CA3.txt','UM19_Test272_CA3.txt','UM19_Test285_CA3.txt','UM19_Test298_CA3.txt','UM19_Test311_CA3.txt','UM19_Test324_CA3.txt','UM19_Test337_CA3.txt'};
BL_Rs_fn.Cell20 = {'UM20_Test167_CA4.txt','UM20_Test180_CA4.txt','UM20_Test194_CA4.txt','UM20_Test206_CA4.txt','UM20_Test220_CA4.txt','UM20_Test233_CA4.txt','UM20_Test246_CA4.txt','UM20_Test259_CA4.txt','UM20_Test272_CA4.txt','UM20_Test285_CA4.txt','UM20_Test298_CA4.txt','UM20_Test311_CA4.txt','UM20_Test324_CA4.txt','UM20_Test337_CA4.txt'};
BL_Rs_fn.Cell21 = {'UM21_Test167_CA5.txt','UM21_Test180_CA5.txt','UM21_Test194_CA5.txt','UM21_Test206_CA5.txt','UM21_Test220_CA5.txt','UM21_Test233_CA5.txt','UM21_Test246_CA5.txt','UM21_Test259_CA5.txt','UM21_Test272_CA5.txt','UM21_Test285_CA5.txt','UM21_Test298_CA5.txt','UM21_Test311_CA5.txt','UM21_Test324_CA5.txt','UM21_Test337_CA5.txt'};
BL_Rs_fn.Cell22 = {'UM22_Test167_CA6.txt','UM22_Test180_CA6.txt','UM22_Test194_CA6.txt','UM22_Test206_CA6.txt','UM22_Test220_CA6.txt','UM22_Test233_CA6.txt','UM22_Test246_CA6.txt','UM22_Test259_CA6.txt','UM22_Test272_CA6.txt','UM22_Test285_CA6.txt','UM22_Test298_CA6.txt','UM22_Test311_CA6.txt','UM22_Test324_CA6.txt','UM22_Test337_CA6.txt'};
BL_Rs_fn.Cell23 = {'UM23_Test167_CA7.txt','UM23_Test180_CA7.txt','UM23_Test194_CA7.txt','UM23_Test206_CA7.txt','UM23_Test220_CA7.txt','UM23_Test233_CA7.txt','UM23_Test246_CA7.txt','UM23_Test259_CA7.txt','UM23_Test272_CA7.txt','UM23_Test285_CA7.txt','UM23_Test298_CA7.txt','UM23_Test311_CA7.txt','UM23_Test324_CA7.txt','UM23_Test337_CA7.txt'};

BL_Rs_fn.Cell27 = {'UM27_Test354_CA1.txt','UM27_Test364_CA1.txt','UM27_Test374_CA1.txt','UM27_Test384_CA1.txt','UM27_Test394_CA1.txt','UM27_Test404_CA1.txt','UM27_Test414_CA1.txt','UM27_Test424_CA1.txt','UM27_Test434_CA1.txt','UM27_Test444_CA1.txt','UM27_Test454_CA1.txt'};
BL_Rs_fn.Cell28 = {'UM28_Test354_CA2.txt','UM28_Test364_CA2.txt','UM28_Test374_CA2.txt','UM28_Test384_CA2.txt','UM28_Test394_CA2.txt','UM28_Test404_CA2.txt','UM28_Test414_CA2.txt','UM28_Test424_CA2.txt','UM28_Test434_CA2.txt','UM28_Test444_CA2.txt','UM28_Test454_CA2.txt','UM28_Test464_CA2.txt'};
BL_Rs_fn.Cell29 = {'UM29_Test354_CA3.txt','UM29_Test364_CA3.txt','UM29_Test374_CA3.txt','UM29_Test384_CA3.txt','UM29_Test394_CA3.txt','UM29_Test404_CA3.txt','UM29_Test414_CA3.txt','UM29_Test424_CA3.txt','UM29_Test434_CA3.txt'};
BL_Rs_fn.Cell30 = {'UM30_Test354_CA4.txt','UM30_Test364_CA4.txt','UM30_Test374_CA4.txt','UM30_Test384_CA4.txt','UM30_Test394_CA4.txt','UM30_Test404_CA4.txt','UM30_Test414_CA4.txt','UM30_Test424_CA4.txt','UM30_Test434_CA4.txt','UM30_Test444_CA4.txt','UM30_Test454_CA4.txt','UM30_Test464_CA4.txt','UM30_Test474_CA4.txt'};
BL_Rs_fn.Cell31 = {'UM31_Test354_CA5.txt','UM31_Test364_CA5.txt','UM31_Test374_CA5.txt','UM31_Test384_CA5.txt','UM31_Test394_CA5.txt','UM31_Test404_CA5.txt','UM31_Test414_CA5.txt','UM31_Test424_CA5.txt','UM31_Test434_CA5.txt','UM31_Test444_CA5.txt','UM31_Test454_CA5.txt','UM31_Test464_CA5.txt','UM31_Test474_CA5.txt','UM31_Test484_CA5.txt'};
BL_Rs_fn.Cell32 = {'UM32_Test354_CA6.txt','UM32_Test364_CA6.txt','UM32_Test374_CA6.txt','UM32_Test384_CA6.txt','UM32_Test394_CA6.txt','UM32_Test404_CA6.txt','UM32_Test414_CA6.txt','UM32_Test424_CA6.txt','UM32_Test434_CA6.txt','UM32_Test444_CA6.txt','UM32_Test454_CA6.txt','UM32_Test464_CA6.txt'}; %,'UM32_Test474_CA6.txt','UM32_Test484_CA6.txt'};
BL_Rs_fn.Cell33 = {'UM33_Test354_CA7.txt','UM33_Test364_CA7.txt','UM33_Test374_CA7.txt','UM33_Test384_CA7.txt','UM33_Test394_CA7.txt','UM33_Test404_CA7.txt','UM33_Test414_CA7.txt'};

BL_Rs_fn.Cell37 = {'UM37_Test424_CA7.txt','UM37_Test428_CA7.txt'};
BL_Rs_fn.Cell38 = {'UM38_Test424_CA3.txt','UM38_Test428_CA3.txt'};
BL_Rs_fn.Cell40 = {'UM40_Test424_CA7.txt','UM40_Test428_CA7.txt'};

lineNum = 108;

BL_OCV_fn.Cell01 = {'UM01_Test002_CA1.txt','UM01_Test016_CA1.txt','UM01_Test028_CA1.txt','UM01_Test040_CA1.txt','UM01_Test058_CA1.txt','UM01_Test076_CA1.txt','UM01_Test094_CA1.txt','UM01_Test115_CA1.txt','UM01_Test136_CA1.txt','UM01_Test156_CA1.txt'};
BL_OCV_fn.Cell02 = {'UM02_Test002_CA2.txt','UM02_Test016_CA2.txt','UM02_Test028_CA2.txt','UM02_Test040_CA2.txt','UM02_Test058_CA2.txt','UM02_Test076_CA2.txt','UM02_Test094_CA2.txt','UM02_Test115_CA2.txt','UM02_Test136_CA2.txt','UM02_Test156_CA2.txt'};
BL_OCV_fn.Cell03 = {'UM03_Test002_CA3.txt','UM03_Test016_CA3.txt','UM03_Test028_CA3.txt','UM03_Test040_CA3.txt','UM03_Test058_CA3.txt','UM03_Test076_CA3.txt','UM03_Test094_CA3.txt'};
BL_OCV_fn.Cell04 = {'UM04_Test002_CA4.txt','UM04_Test016_CA4.txt','UM04_Test028_CA4.txt','UM04_Test040_CA4.txt','UM04_Test058_CA4.txt','UM04_Test076_CA4.txt','UM04_Test094_CA4.txt','UM04_Test115_CA4.txt','UM04_Test136_CA4.txt','UM04_Test156_CA4.txt'};
BL_OCV_fn.Cell05 = {'UM05_Test002_CA5.txt','UM05_Test016_CA5.txt','UM05_Test028_CA5.txt','UM05_Test040_CA5.txt','UM05_Test058_CA5.txt','UM05_Test076_CA5.txt','UM05_Test094_CA5.txt','UM05_Test115_CA5.txt','UM05_Test136_CA5.txt','UM05_Test156_CA5.txt'};
BL_OCV_fn.Cell06 = {'UM06_Test002_CA6.txt','UM06_Test016_CA6.txt','UM06_Test028_CA6.txt','UM06_Test040_CA6.txt','UM06_Test058_CA6.txt','UM06_Test076_CA6.txt','UM06_Test094_CA6.txt','UM06_Test115_CA6.txt','UM06_Test136_CA6.txt','UM06_Test156_CA6.txt'};
BL_OCV_fn.Cell07 = {'UM07_Test002_CA7.txt','UM07_Test016_CA7.txt','UM07_Test028_CA7.txt','UM07_Test040_CA7.txt','UM07_Test058_CA7.txt','UM07_Test076_CA7.txt','UM07_Test094_CA7.txt'};
BL_OCV_fn.Cell09 = {'UM09_Test103_CA3.txt','UM09_Test115_CA3.txt'};
BL_OCV_fn.Cell10 = {'UM10_Test103_CA7.txt','UM10_Test115_CA7.txt'};
BL_OCV_fn.Cell12 = {'UM12_Test124_CA3.txt','UM12_Test136_CA3.txt'};
BL_OCV_fn.Cell13 = {'UM13_Test124_CA7.txt','UM13_Test136_CA7.txt'};
BL_OCV_fn.Cell15 = {'UM15_Test145_CA3.txt','UM15_Test156_CA3.txt'};
BL_OCV_fn.Cell16 = {'UM16_Test145_CA7.txt','UM16_Test156_CA7.txt'};
BL_OCV_fn.Cell17 = {'UM17_Test165_CA1.txt','UM17_Test178_CA1.txt','UM17_Test192_CA1.txt','UM17_Test205_CA1.txt','UM17_Test218_CA1.txt','UM17_Test231_CA1.txt','UM17_Test244_CA1.txt','UM17_Test257_CA1.txt','UM17_Test270_CA1.txt','UM17_Test283_CA1.txt','UM17_Test296_CA1.txt','UM17_Test309_CA1.txt','UM17_Test322_CA1.txt','UM17_Test335_CA1.txt'};
BL_OCV_fn.Cell18 = {'UM18_Test165_CA2.txt','UM18_Test178_CA2.txt','UM18_Test192_CA2.txt','UM18_Test205_CA2.txt','UM18_Test218_CA2.txt','UM18_Test231_CA2.txt','UM18_Test244_CA2.txt','UM18_Test257_CA2.txt','UM18_Test270_CA2.txt','UM18_Test283_CA2.txt','UM18_Test296_CA2.txt','UM18_Test309_CA2.txt','UM18_Test322_CA2.txt','UM18_Test335_CA2.txt'};
BL_OCV_fn.Cell19 = {'UM19_Test165_CA3.txt','UM19_Test178_CA3.txt','UM19_Test192_CA3.txt','UM19_Test205_CA3.txt','UM19_Test218_CA3.txt','UM19_Test231_CA3.txt','UM19_Test244_CA3.txt','UM19_Test257_CA3.txt','UM19_Test270_CA3.txt','UM19_Test283_CA3.txt','UM19_Test296_CA3.txt','UM19_Test309_CA3.txt','UM19_Test322_CA3.txt','UM19_Test335_CA3.txt'};
BL_OCV_fn.Cell20 = {'UM20_Test165_CA4.txt','UM20_Test178_CA4.txt','UM20_Test192_CA4.txt','UM20_Test205_CA4.txt','UM20_Test218_CA4.txt','UM20_Test231_CA4.txt','UM20_Test244_CA4.txt','UM20_Test257_CA4.txt','UM20_Test270_CA4.txt','UM20_Test283_CA4.txt','UM20_Test296_CA4.txt','UM20_Test309_CA4.txt','UM20_Test322_CA4.txt','UM20_Test335_CA4.txt'};
BL_OCV_fn.Cell21 = {'UM21_Test165_CA5.txt','UM21_Test178_CA5.txt','UM21_Test192_CA5.txt','UM21_Test205_CA5.txt','UM21_Test218_CA5.txt','UM21_Test231_CA5.txt','UM21_Test244_CA5.txt','UM21_Test257_CA5.txt','UM21_Test270_CA5.txt','UM21_Test283_CA5.txt','UM21_Test296_CA5.txt','UM21_Test309_CA5.txt','UM21_Test322_CA5.txt','UM21_Test335_CA5.txt'};
BL_OCV_fn.Cell22 = {'UM22_Test165_CA6.txt','UM22_Test178_CA6.txt','UM22_Test192_CA6.txt','UM22_Test205_CA6.txt','UM22_Test218_CA6.txt','UM22_Test231_CA6.txt','UM22_Test244_CA6.txt','UM22_Test257_CA6.txt','UM22_Test270_CA6.txt','UM22_Test283_CA6.txt','UM22_Test296_CA6.txt','UM22_Test309_CA6.txt','UM22_Test322_CA6.txt','UM22_Test335_CA6.txt'};
BL_OCV_fn.Cell23 = {'UM23_Test165_CA7.txt','UM23_Test178_CA7.txt','UM23_Test192_CA7.txt','UM23_Test205_CA7.txt','UM23_Test218_CA7.txt','UM23_Test231_CA7.txt','UM23_Test244_CA7.txt','UM23_Test257_CA7.txt','UM23_Test270_CA7.txt','UM23_Test283_CA7.txt','UM23_Test296_CA7.txt','UM23_Test309_CA7.txt','UM23_Test322_CA7.txt','UM23_Test335_CA7.txt'};

BL_OCV_fn.Cell27 = {'UM27_Test351_CA1.txt','UM27_Test362_CA1.txt','UM27_Test372_CA1.txt','UM27_Test382_CA1.txt','UM27_Test392_CA1.txt','UM27_Test402_CA1.txt','UM27_Test412_CA1.txt','UM27_Test422_CA1.txt','UM27_Test432_CA1.txt','UM27_Test442_CA1.txt','UM27_Test452_CA1.txt'};
BL_OCV_fn.Cell28 = {'UM28_Test351_CA2.txt','UM28_Test362_CA2.txt','UM28_Test372_CA2.txt','UM28_Test382_CA2.txt','UM28_Test392_CA2.txt','UM28_Test402_CA2.txt','UM28_Test412_CA2.txt','UM28_Test422_CA2.txt','UM28_Test432_CA2.txt','UM28_Test442_CA2.txt','UM28_Test452_CA2.txt','UM28_Test462_CA2.txt'};
BL_OCV_fn.Cell29 = {'UM29_Test351_CA3.txt','UM29_Test362_CA3.txt','UM29_Test372_CA3.txt','UM29_Test382_CA3.txt','UM29_Test392_CA3.txt','UM29_Test402_CA3.txt','UM29_Test412_CA3.txt','UM29_Test422_CA3.txt','UM29_Test432_CA3.txt'};
BL_OCV_fn.Cell30 = {'UM30_Test351_CA4.txt','UM30_Test362_CA4.txt','UM30_Test372_CA4.txt','UM30_Test382_CA4.txt','UM30_Test392_CA4.txt','UM30_Test402_CA4.txt','UM30_Test412_CA4.txt','UM30_Test422_CA4.txt','UM30_Test432_CA4.txt','UM30_Test442_CA4.txt','UM30_Test452_CA4.txt','UM30_Test462_CA4.txt','UM30_Test472_CA4.txt'};%,'UM30_Test482_CA4.txt'};
BL_OCV_fn.Cell31 = {'UM31_Test351_CA5.txt','UM31_Test362_CA5.txt','UM31_Test372_CA5.txt','UM31_Test382_CA5.txt','UM31_Test392_CA5.txt','UM31_Test402_CA5.txt','UM31_Test412_CA5.txt','UM31_Test422_CA5.txt','UM31_Test432_CA5.txt','UM31_Test442_CA5.txt','UM31_Test452_CA5.txt','UM31_Test462_CA5.txt','UM31_Test472_CA5.txt','UM31_Test482_CA5.txt'};
BL_OCV_fn.Cell32 = {'UM32_Test351_CA6.txt','UM32_Test362_CA6.txt','UM32_Test372_CA6.txt','UM32_Test382_CA6.txt','UM32_Test392_CA6.txt','UM32_Test402_CA6.txt','UM32_Test412_CA6.txt','UM32_Test422_CA6.txt','UM32_Test432_CA6.txt','UM32_Test442_CA6.txt','UM32_Test452_CA6.txt','UM32_Test462_CA6.txt'};
BL_OCV_fn.Cell33 = {'UM33_Test351_CA7.txt','UM33_Test362_CA7.txt','UM33_Test372_CA7.txt','UM33_Test382_CA7.txt','UM33_Test392_CA7.txt','UM33_Test402_CA7.txt','UM33_Test412_CA7.txt'};

BL_OCV_fn.Cell37 = {'UM37_Test422_CA7.txt','UM37_Test426_CA7.txt'};
BL_OCV_fn.Cell38 = {'UM38_Test422_CA3.txt','UM38_Test426_CA3.txt'};
BL_OCV_fn.Cell40 = {'UM40_Test422_CA7.txt','UM40_Test426_CA7.txt'};


% % Different pressures '*':5 PSI 's':10 PSI 'd':15 PSI 'o':20 PSI
% Path = {'Cell10','Cell07','Cell13','Cell09','Cell12','Cell15','Cell37','Cell16','Cell38','Cell40'};
% color = {'y-*','b-*','b-*','g-s','g-s','r-d','r-d','k-o','k-o','m-o','m-o'};

% Path = {'Cell01','Cell03','Cell07','Cell17','Cell19','Cell23','Cell27','Cell29','Cell33'};
% Path = {'Cell32'};
color = {'-*','-*','-*','-s','-s','-s','-d','-d','-d','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*','*'};
% startColor = [0.8500 0.3250 0.0980];

% % ALL Same Pressure = 5 PSI, Different Conditions; Cell06 needs to be
% added separately, Cell10 is the outlier
% Path = {'Cell01','Cell02','Cell03','Cell04','Cell05','Cell06','Cell07'};
% Path = {'Cell17','Cell18','Cell19','Cell20','Cell21','Cell22','Cell23'};

% color = {'*','*','*','*','*','*','*','*','*'};

% Path = {'Cell01','Cell03','Cell07','Cell02','Cell04','Cell05','Cell06'};
marker = '-o';
colormap_m = colorGradient([0.85,0.33,0.10],[0.64,0.08,0.18],21);
startColor = [0.8500 0.3250 0.0980];

colormap_grey = colorGradient([0.25,0.25,0.25],[0.83,0.82,0.78],9);
% Path = {'Cell17','Cell19','Cell23','Cell18','Cell20','Cell21','Cell22'};
% marker = '-s';
% colormap_m = colorGradient([0.00,0.45,0.74],[0.08,0.17,0.55],7);
% startColor = [0 0.4470 0.7410];

% Path = {'Cell27','Cell29','Cell33','Cell28','Cell30','Cell31','Cell32'};
Path = {'Cell17','Cell19','Cell23','Cell18','Cell20','Cell21','Cell22','Cell01','Cell02','Cell03','Cell04','Cell05','Cell06','Cell07'};
Path = {'Cell07','Cell23','Cell33'};

% marker = '-d';
% colormap_m = colorGradient([0.47,0.67,0.19],[0.00,0.50,0.00],7);
% startColor = [0.4660 0.6740 0.1880];

%%
for j = 1:length(Path)
strPath = Path{j};

Cy_num = 0;
Cap_before = 5;
Char = ['BL_fn.',Path{j}];
BL_fn.main = eval(Char);

 Capac = [];
 Cycle_num = [];
 Cy_num_OCV = 0;
 Ah_Tot_OCV = 0;
 Ah_cycle = 0;

% Load cycling data
for k = 1:length(eval(Char))
  
C1 = 0;
d1 = 1;

strFull1 = fullfile(strPath,BL_fn.main{k});
% strFull2 = fullfile(strPath,KS_fn{i});
fid = fopen(strFull1,'rt');

% [ConvertedData,~,~]=convertTDMS(0,strFull2);


% fid = fopen('./Cell01/UM01_Test001_CA1.txt');
 if fid>0
     % note how we skip the header lines and use the delimiter
     data = textscan(fid, '%s', lineNum, 'delimiter', '\n');
     C = textscan(fid, '%f %f %f %f %f %f %f','delimiter','\t');
     % close the file
     fclose(fid);
     % grab the date and time column
     dateAndTimeData = textscan(data{1}{14},'%s %s %s:%s %s');
     % convert to serial
     dateAndTimeSerial_BL = datenum([dateAndTimeData{4}{1},' ',dateAndTimeData{5}{1}],'mm/dd/yyyy HH:MM:SS');
 end


Time_BL = C{1,1}; % suhak got an error
Voltage = C{1,2}; %V
Current = C{1,3}; %A
Q = C{1,4}/1000;  %Ah
Temperature = C{1,5}; %C
Capacity = C{1,6}/1000; %A.h	
cycle_number = C{1,7};

Ah_Tot = sum((abs(Current(1:end-1))+abs(Current(2:end))).*(Time_BL(2:end)-Time_BL(1:end-1))./2./3600./1000);

Ah_Tot_OCV = [Ah_Tot_OCV,Ah_Tot+Ah_Tot_OCV(end)];

 
 for kk = 0:cycle_number(end)
    if C1 == max(cycle_number)
        d2 = length(cycle_number);
    else
        d2 = find(cycle_number>C1,1);
    end
    
    Cap = max(Capacity(d1:d2));
%     Cap = max(Capacity(find(Current(d1:d2)<0,1)+d1:d2));
    
    if Cap < 0.95*Cap_before && kk ~= 0
            Capac = [Capac, NaN];
        Cycle_num = [Cycle_num, C1+Cy_num];
    else
    Cap_before = Cap;
    Capac = [Capac, Cap];
    Cycle_num = [Cycle_num, C1+Cy_num];
    end
    Ah_cycle = [Ah_cycle,Ah_cycle(end)+sum((abs(Current(d1:d2-1))+abs(Current(d1+1:d2))).*(Time_BL(d1+1:d2)-Time_BL(d1:d2-1))./2./3600./1000)];
    C1 = C1+1;
    d1 = d2+1;
 end
 
 if Path{j} == 'Cell12'
     s = find(Cycle_num>25,1);
     Cycle_num(s:end) = Cycle_num(s:end)+12; 
 elseif Path{j} == 'Cell13'
     s = find(Cycle_num>25,1);
     Cycle_num(s:end) = Cycle_num(s:end)+12;
 end

Cy_num = Cy_num + cycle_number(end)+1;

Cy_num_OCV = [Cy_num_OCV,Cy_num];
end

if Path{j} == 'Cell38'
    Cy_num_OCV = [Cy_num_OCV(1),Cy_num_OCV(end)];
end

    figure(1)
    plot(Cycle_num,Capac,color{j})
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('Capacity [Ah]','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
    figure(3)
    plot(Ah_cycle(1:length(Capac)),Capac,color{j})
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('Capacity [Ah]','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
    figure(2)
    plot(Cycle_num,Capac./Capac(1).*100,color{j})
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('SOH $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    set(h,'Interpreter','latex','Location','best')
    hold on

% load C/20 data for capacity measure
Char_OCV = ['BL_OCV_fn.',Path{j}];
BL_OCV_fn.main = eval(Char_OCV);
Capac_OCV = [];
Rs_ave = [];

for i = 1:length(eval(Char_OCV))

strFull2 = fullfile(strPath,BL_OCV_fn.main{i});

fid = fopen(strFull2,'rt');

 if fid>0
     % note how we skip the header lines and use the delimiter
     data = textscan(fid, '%s', lineNum, 'delimiter', '\n');
     C = textscan(fid, '%f %f %f %f %f %f','delimiter','\t');
     % close the file
     fclose(fid);
     % grab the date and time column
     dateAndTimeData = textscan(data{1}{14},'%s %s %s:%s %s');
     % convert to serial
     dateAndTimeSerial_BL = datenum([dateAndTimeData{4}{1},' ',dateAndTimeData{5}{1}],'mm/dd/yyyy HH:MM:SS');
 end

 Time_BL = C{1,1};
 
 Voltage = C{1,2}; %V
 Current = C{1,3}; %A
 Q = C{1,4}/1000; %Ah
 Temperature = C{1,5}; %C
 Capacity = C{1,6}/1000; %A.h
 
 Capac_OCV = [Capac_OCV,max(Capacity)];
 
%  diff = Current(2:end)-Current(1:end-1);
 I1 = find(diff(Current) > 240);
 Sstart = Current(I1+1);
 if Cy_num_OCV(i) == 184
     dd= 1;
 end
 
 for jj = 1:length(Sstart)
     if 240 < Sstart(jj) && Sstart(jj) < 300
         Spoint = I1(jj)+1;
%          Epoint = find(Current(Spoint:end) < 200,1) + Spoint -1
         
         % suhak edited
         I2 = find(Voltage > 4.2);
         if length(I2) > 1 
            Epoint = min(I2(I2>Spoint));
         else 
            Epoint = I2 ;
         end
     end
 end
 
end
    
%% load HPPC & GEIS Test data
Char_Rs = ['BL_Rs_fn.',Path{j}];
BL_Rs_fn.main = eval(Char_Rs);

    R0_est = [];
    R1_est = [];
    C1_est = [];
%     R2_est{k,i} = R2;
%     C2_est{k,i} = C2;
    RMSE_ECM = [];
    
    Rs_ave = [];
Rs_80 = [];
Rs_ave2 = [];
Rs_80_2 = []; 
Rs_10_2 = [];
DCR_ave = []; DCR_dch = [];  DCR_ch = []; RTC_ave = []; ZTR = [];
RTC = [];
colormap = colorGradient([0.00,0.80,0.40],[0.80,0.00000001,0.20],length(eval(Char_Rs)));
for k = 1:length(eval(Char_Rs))

strFull2 = fullfile(strPath,BL_Rs_fn.main{k});

fid = fopen(strFull2,'rt');
lineNum2 = 103;

 if fid>0
     % note how we skip the header lines and use the delimiter
     data = textscan(fid, '%s', lineNum2, 'delimiter', '\n');
     Header = textscan(fid, '%s %s %s %s %s %s %s %s %s %s', 1, 'delimiter', '\t');
     C = textscan(fid,      '%f %f %f %f %f %f %f %f %f %f','delimiter','\t');
     % close the file
     fclose(fid);
     % grab the date and time column
     dateAndTimeData = textscan(data{1}{14},'%s %s %s:%s %s');
     % convert to serial
     dateAndTimeSerial_BL = datenum([dateAndTimeData{4}{1},' ',dateAndTimeData{5}{1}],'mm/dd/yyyy HH:MM:SS');
 end

% for k = 1:length(Header)
%     figure
%     plot(C{1,k})
%     title(Header{1,k})
% end

% assign data variable 
Time_BL = C{1,1};
Voltage = C{1,2}; %V
Current = C{1,3}; %mA
Q = C{1,4}/1000; %Ah
Freq = C{1,5}; %Freq/Hz
Magnitude = C{1,6}; %|Z|/Ohm
Phase = C{1,7}; %Phase(Z)/deg
Temperature = C{1,8}; %Temperature/degC
Re = C{1,9}; %Re(Z)/Ohm
m_Im = C{1,10}; %-Im(Z)/Ohm

% --- export Pulse data --- suhak added
Idx_dischg = find(diff(Current) < -4900); 
for i = 1:length(Idx_dischg)/2
    if i > 9
        continue
    end
    Idx_pulse = Idx_dischg(2*i-1):Idx_dischg(2*i)+600; % extract pulsing
    [R0,R1,C1,RMSE] = ECM_estimate(Time_BL(Idx_pulse),Voltage(Idx_pulse),Current(Idx_pulse));
%     [R0,R1,C1,R2,C2,RMSE] = ECM_estimate(Time_BL(Idx_pulse),Voltage(Idx_pulse),Current(Idx_pulse));
    R0_est{k,i} = R0;
    R1_est{k,i} = R1;
    C1_est{k,i} = C1;
%     R2_est{k,i} = R2;
%     C2_est{k,i} = C2;
    RMSE_ECM{k,i} = RMSE;
    idit = find(Current(Idx_pulse)>0,1)+Idx_pulse(1)-1;
    DCR_dch(k,i) = (Voltage(Idx_pulse(1))-Voltage(Idx_pulse(2)))/5;
    DCR_ch(k,i) = (Voltage(idit)-Voltage(idit-1))/5;
    DCR_ave(k,i) = (DCR_dch(k,i) + DCR_ch(k,i))/2;
end


% --- export CV data --- Suhak added
Idx = find(Voltage > 4.1995 & Current < 2800);
CV_time = Time_BL(Idx) - Time_BL(Idx(1));
CV_I = Current(Idx);
CV_V = Voltage(Idx);

f1 = figure(33);
plot(CV_time,CV_I,'linewidth',2);
xlabel('Time [sec]','Interpreter','LaTex');
ylabel('CV current [mA]','Interpreter','LaTex');
set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
h = legend(string(round(Ah_Tot_OCV)));
hold on;

CV{k,1} = CV_time;
CV{k,2} = CV_I;

% --- export EIS data ---

% figure(3)
% plot(Re(I),m_Im(I))
% hold on

I = find(m_Im ~= 0);
MM = I(2:end)-I(1:end-1)-1;
M = [0;find(MM ~= 0);length(I)];

Rs_a = [];
Header_EIS = [Header(1,5),Header(1,6),Header(1,7),Header(1,9),Header(1,10)]; % Freq|Magnitude(Z)|Phase(Z)|Re(Z)|-Im(Z)

for lk = 1:length(M)-1
%     if lk > 9
%         continue
%     end
    figure(300+lk)
    plot(Re(I(M(lk)+1):I(M(lk+1))),m_Im(I(M(lk)+1):I(M(lk+1))),'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    title(['SOC=',num2str(100-lk*10),'%'],'Interpreter','LaTex')
    xlabel('Re(Z) [Ohm]','Interpreter','LaTex');
    ylabel('-Im(Z) [Ohm]','Interpreter','LaTex');
    ylim([-10e-3 10e-3])
    xlim([0.003 0.023])
    colororder(colormap)
    hold on
    
    figure(400)
    plot(Re(I(M(lk)+1):I(M(lk+1))),m_Im(I(M(lk)+1):I(M(lk+1))),'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    title(['SOC=',num2str(100-lk*10),'%'],'Interpreter','LaTex')
    xlabel('Re(Z) [Ohm]','Interpreter','LaTex');
    ylabel('-Im(Z) [Ohm]','Interpreter','LaTex');
    ylim([-10e-3 10e-3])
    xlim([0.003 0.023])
    colororder(colormap_grey)
    hold on
    
    EIS{k,lk,1} = Freq(I(M(lk)+1):I(M(lk+1)));
    EIS{k,lk,2} = Magnitude(I(M(lk)+1):I(M(lk+1)));
    EIS{k,lk,3} = Phase(I(M(lk)+1):I(M(lk+1)));
    EIS{k,lk,4} = Re(I(M(lk)+1):I(M(lk+1)));
    EIS{k,lk,5} = m_Im(I(M(lk)+1):I(M(lk+1)));
    
%     m_Im_c = m_Im(I(M(lk)+1):I(M(lk+1)));
    Rs = interp1(m_Im(I(M(lk)+1):I(M(lk+1))),Re(I(M(lk)+1):I(M(lk+1))),0);
    if isnan(Rs)
        Rs = Re(I(M(lk)+1));%-(m_Im_c(2)-m_Im_c(1))/(Re(I(M(k)+2))-Re(I(M(k)+1)))*Re(I(M(k)+1)) +  m_Im_c(1)
%         Cy_num_OCV(k)
    end
    Rs_a = [Rs Rs_a];
    
    m_IM_c = m_Im(I(M(lk)+1):I(M(lk+1)));
    m_Re_c = Re(I(M(lk)+1):I(M(lk+1)));
    Mag_c = Magnitude(I(M(lk)+1):I(M(lk+1)));
%     [~, min_id] = min(m_IM_c(length(m_IM_c)-16:length(m_IM_c)));
%     min_id = min_id+length(m_IM_c)-16-1;
%     ZTR(k,lk) = Mag_c(min_id);
%     [~, max_id] = max(m_IM_c(1:min_id));
%     RTC(k,lk) = m_Re_c(min_id) - m_Re_c(max_id) + m_IM_c(max_id) - m_IM_c(min_id);
    
    neg_id = find(diff(m_IM_c)<0);
    last_circle_id = find(diff(neg_id)>1);
    if isempty(last_circle_id)
        max_id = neg_id(1);
    else
        max_id = neg_id(last_circle_id(length(last_circle_id))+1);
    end
    min_id = neg_id(end)+1;
    
    ZTR(k,lk) = Mag_c(min_id);
    RTC(k,lk) = m_Re_c(min_id) - m_Re_c(max_id)+ m_IM_c(max_id) - m_IM_c(min_id);
end
    figure(1000+j)
%     plot(100-(1:length(M)-1)*10,Rs_a,'s-','LineWidth',1.5) % this is wrong
    plot(100-(1:length(Rs_a))*10,(ZTR(k,1:length(Rs_a)))*1e3,'s-','LineWidth',1.5) % suhak edited
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
    xlabel('SoC $[\%]$','Interpreter','LaTex');
    ylabel('$ZTR$ [mOhm]','Interpreter','LaTex');
    colororder(colormap)
%     h = legend(string(Cy_num_OCV));
    hold on
    
    figure(2000+j)
%     plot(100-(1:length(M)-1)*10,Rs_a,'s-','LineWidth',1.5) % this is wrong
    plot(100-(1:length(Rs_a))*10,(RTC(k,1:length(Rs_a)))*1e3,'s-','LineWidth',1.5) % suhak edited
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
    xlabel('SoC $[\%]$','Interpreter','LaTex');
    ylabel('$RTC$ [mOhm]','Interpreter','LaTex');
    colororder(colormap)
%     h = legend(string(Cy_num_OCV));
    hold on
    
    figure(100+j)
%     plot(100-(1:length(M)-1)*10,Rs_a,'s-','LineWidth',1.5) % this is wrong
    plot((1:length(Rs_a))*10,Rs_a,'s-','LineWidth',1.5) % suhak edited
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
    xlabel('SoC $[\%]$','Interpreter','LaTex');
    ylabel('$R_s$ [Ohm]','Interpreter','LaTex');
    colororder(colormap)
%     h = legend(string(Cy_num_OCV));
    hold on
    
%      if Path{j} == 'Cell15'
%          if k == 1
%              Rs_a = 4.685e-3; 
%          end
%      elseif Path{j} == 'Cell16' 
%          if k ==1
%              Rs_a = 4.612e-3;
%          end
%      elseif Path{j} == 'Cell38'
%          if k ==2
%              Rs_a = 8.101e-3;
%          end
%      end
%     Rs_ave(k) = mean(Rs_a);

% plotting R0,R1,C1,tau at SOCs over cycle 
%     figure(200+j)
%     plot((100-(1:length(R0_est(k,:)))*10),cell2mat(R0_est(k,:)),'s-','LineWidth',1.5) % suhak edited
%     set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% %     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
%     xlabel('SOC $[\%]$','Interpreter','LaTex');
%     ylabel('$R_0$ [Ohm]','Interpreter','LaTex');
%     colororder(colormap)
%     h = legend(string(round(Capac_OCV/Capac_OCV(1)*100)));
%     hold on
%     
%     figure(201+j)
%     plot((100-(1:length(R0_est(k,:)))*10),cell2mat(R1_est(k,:)),'s-','LineWidth',1.5) % suhak edited
%     set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% %     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
%     xlabel('SOC $[\%]$','Interpreter','LaTex');
%     ylabel('$R_1$ [Ohm]','Interpreter','LaTex');
%     colororder(colormap)
%     h = legend(string(round(Capac_OCV/Capac_OCV(1)*100)));
%     hold on
%     
%     figure(202+j)
%     plot((100-(1:length(R0_est(k,:)))*10),cell2mat(C1_est(k,:)),'s-','LineWidth',1.5) % suhak edited
%     set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% %     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
%     xlabel('SOC $[\%]$','Interpreter','LaTex');
%     ylabel('$C_1$ [F]','Interpreter','LaTex');
%     colororder(colormap)
%     h = legend(string(round(Capac_OCV/Capac_OCV(1)*100)));
%     hold on
% 
%     figure(203+j)
%     plot((100-(1:length(R0_est(k,:)))*10),cell2mat(R1_est(k,:)).*cell2mat(C1_est(k,:)),'s-','LineWidth',1.5) % suhak edited
%     set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
% %     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
%     xlabel('SOC $[\%]$','Interpreter','LaTex');
%     ylabel('$R_1C_1$ [sec]','Interpreter','LaTex');
%     colororder(colormap)
%     h = legend(string(round(Capac_OCV/Capac_OCV(1)*100)));
%     hold on
    
    figure(204+j)
    plot((100-(1:length(DCR_dch(k,:)))*10),DCR_dch(k,:),'s-','LineWidth',1.5) % suhak edited
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
    xlabel('SOC $[\%]$','Interpreter','LaTex');
    ylabel('$DCR_{dch}$ [Ohm]','Interpreter','LaTex');
    h = legend(string(round(Capac_OCV/Capac_OCV(1)*100)));
    hold on
%     
    figure(205+j)
    plot((100-(1:length(DCR_dch(k,:)))*10),DCR_ch(k,:),'s-','LineWidth',1.5) % suhak edited
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
    xlabel('SOC $[\%]$','Interpreter','LaTex');
    ylabel('$DCR_{ch}$ [Ohm]','Interpreter','LaTex');
    h = legend(string(round(Capac_OCV/Capac_OCV(1)*100)));
    hold on

    figure(1206)
    plot((100-(1:length(DCR_dch(k,:)))*10),DCR_ave(k,:),marker,'Color',colormap_m(j,:),'LineWidth',1.5) % suhak edited
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
    xlabel('SOC $[\%]$','Interpreter','LaTex');
    ylabel('$DCR_{ave}$ [Ohm]','Interpreter','LaTex');
    h = legend(string(round(Capac_OCV/Capac_OCV(1)*100)));
    hold on
    
    figure(1207)
    plot((100-(1:length(DCR_dch(k,:)))*10),DCR_ave(k,:),marker,'LineWidth',1.5) % suhak edited
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     title(['SOC=',num2str(100-k*10),'%'],'Interpreter','LaTex')
    xlabel('SOC $[\%]$','Interpreter','LaTex');
    ylabel('$DCR$ [Ohm]','Interpreter','LaTex');
    h = legend(string(round(Capac_OCV/Capac_OCV(1)*100)));
    hold on
    colororder(colormap)
    
%     figure(207+j)
%     plot((100-(1:length(R0_est(k,:)))*10),cell2mat(RMSE_ECM(k,:))*10^3,'s-','LineWidth',1.5) % suhak edited
%     set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     xlabel('SOC $[\%]$','Interpreter','LaTex');
%     ylabel('RMSE [mV]','Interpreter','LaTex');
%     colororder(colormap)
%     h = legend(string(round(Capac_OCV/Capac_OCV(1)*100)));
%     hold on

% Rs_ave(k) = Rs_a(5);
% Rs_ave(k) = mean(Rs_a);
Rs_ave(k) = mean(DCR_ave(k,:));
Rs_50(k) = Rs_a(5);
Rs_ave2(k) = mean(cell2mat(R0_est(k,:)));
Rs_80_2(k) = cell2mat(R0_est(k,8)); 
Rs_10_2(k) = cell2mat(R0_est(k,1)); 
RTC_80(k) = mean(RTC(k,2));
ZTC_80(k) = mean(ZTR(k,2));
RTC_ave(k) = mean(RTC(k,:));
end

    figure(121)
    plot(Ah_Tot_OCV(1:length(Rs_ave)),Rs_ave.*1e3,marker,'Color',colormap_m(j,:),'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Ah throughput [Ah]','Interpreter','LaTex');
    ylabel('$R_s$ Increase [mOhm]','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
%     f2 = figure(122);
%     plot(Ah_Tot_OCV(1:length(Rs_ave)),Rs_ave./Rs_ave(1).*100-100,'-*','Color', startColor,'LineWidth',1.5)
%     set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     xlabel('Ah throughput [Ah]','Interpreter','LaTex');
%     ylabel('$R_s$ Increase $[\%]$','Interpreter','LaTex');
%     h = legend(Path);
%     hold on

    figure(122);
    plot(Ah_Tot_OCV(1:length(Rs_ave)),Rs_ave./Rs_ave(1).*100-100,marker,'Color',colormap_m(j,:),'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Ah throughput [Ah]','Interpreter','LaTex');
    ylabel('$DCR_{avg}$ Increase $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
    figure(123);
    plot(Rs_ave./Rs_ave(1).*100-100,Capac_OCV./Capac_OCV(1).*100,marker,'Color',colormap_m(j,:),'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    ylabel('C/20 @$25^oC$ Capacity Retention $[\%]$','Interpreter','LaTex');
    xlabel('$DCR_{avg}$ Increase $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
    figure(125);
    plot(RTC_ave./RTC_ave(1).*100-100,Capac_OCV./Capac_OCV(1).*100,marker,'Color',colormap_m(j,:),'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    ylabel('C/20 @$25^oC$ Capacity Retention $[\%]$','Interpreter','LaTex');
    xlabel('$RTC_{avg}$ Increase $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
    if Path{j} == 'Cell07'
        id = [1,length(Rs_ave)];
    else
        id = 1:length(Rs_ave);
    end
    
    figure(1221);
    plot(Cy_num_OCV(id),Rs_ave(id)./Rs_ave(1).*100-100,color{j},'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Cycle number','Interpreter','LaTex');
    ylabel('$R_s$ Increase $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
    
    
    figure(1222);
    plot(Capac_OCV./Capac_OCV(1).*100,Rs_ave2./Rs_ave2(1).*100-100,color{j},'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex','Xdir','reverse')
    xlabel('SOH $[\%]$','Interpreter','LaTex');
    ylabel('$R_s^{avg}$ Increase $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
    figure(1223);
    plot(Ah_Tot_OCV,Rs_50(1:length(Ah_Tot_OCV)),color{j},'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Ah throughput [Ah]','Interpreter','LaTex');
    ylabel('$R_s^{50}$ Increase $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
    figure(1224);
    plot(Capac_OCV./Capac_OCV(1).*100,Rs_10_2./Rs_10_2(1).*100-100,color{j},'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex','Xdir','reverse')
    xlabel('SOH $[\%]$','Interpreter','LaTex');
    ylabel('$R_s^{10}$ Increase $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
    figure(1225);
    plot(Ah_Tot_OCV,RTC_ave(1:length(Ah_Tot_OCV))./RTC_ave(1).*100-100,color{j},'LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Ah throughput [Ah]','Interpreter','LaTex');
    ylabel('$RTC_{80}$ Increase $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    hold on
    
%     figure(123)
%     plot(Cy_num_OCV(1:length(Capac_OCV)),Capac_OCV,'s-','LineWidth',1.5)
%     set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
%     xlabel('Cycle number','Interpreter','LaTex');
%     ylabel('Capacity [Ah]','Interpreter','LaTex');
%     h = legend(Path);
%     hold on
    
    f3 = figure(124);
    plot(Ah_Tot_OCV(1:length(Capac_OCV)),Capac_OCV./Capac_OCV(1).*100,'s-','LineWidth',1.5)
    set(gca,'fontsize',16,'TickLabelInterpreter','LaTex')
    xlabel('Ah throughput [Ah]','Interpreter','LaTex');
    ylabel('Capacity Fade $[\%]$','Interpreter','LaTex');
    h = legend(Path);
    hold on

%     % save CV fig
%     savefig(f1,[Path{j},'_CV','.fig']);
%     savefig(f2,[Path{j},'_Rs','.fig']);
%     savefig(f3,[Path{j},'_Capacity','.fig']);
%     
%     % save CV data in mat file
%     save([Path{j},'.mat'], 'CV', 'Ah_Tot_OCV', 'Rs_ave','Capac_OCV')
    
%     size(Ah_Tot_OCV)
%     size(Rs_ave)
%     size(Capac_OCV)

    % save Pulse test data in mat file
%     save([Path{j},'_ECM_R-RC_chg.mat'], 'R0_est','R1_est','C1_est','Capac_OCV','RMSE_ECM')
%     save([Path{j},'_ECM_R-RC-RC.mat'], 'R0_est','R1_est','C1_est','Capac_OCV','R2_est','C2_est','RMSE_ECM')

startColor = startColor + ([1 1 1] - startColor)./7;
% close all
% save(['Processed\',Path{j},'_resistance','.mat'],'Rs_ave');
end



