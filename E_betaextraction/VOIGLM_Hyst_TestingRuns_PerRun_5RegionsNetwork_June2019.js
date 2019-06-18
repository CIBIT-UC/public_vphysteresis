BrainVoyager.ShowLogTab();

// DEFINE STUFF
var dataRoot = 'F:\\DATA_VP_Hysteresis_TAL';

 var subs = ['TestSubject01','TestSubject02'];
			  	  
// 1 - Adaptation , 2 - Persistence , 3 - None, 0 - Undefined
var subs_group_pc =  [ [1,1,1,1],
						[2,3,2,3],
						[2,0,0,0],
						[0,2,1,0],
						[3,3,0,3],
						[0,2,0,2],
						[3,0,2,2],
						[1,1,1,1],
						[1,3,1,3],
						[1,1,1,1],
						[3,2,1,1],
						[0,0,0,0],
						[1,1,1,1],
						[1,1,1,1],
						[0,3,2,3],
						[3,3,1,1],
						[0,0,1,0],
						[1,1,1,1],
						[1,0,1,0],
						[0,1,0,2],
						[3,3,3,3],
						[1,1,1,1],
						[1,1,1,1],
						[3,1,1,1],
						[1,3,2,3] ];
					 
var subs_group_cp = [ [2,2,2,2],
						[2,2,2,2],
						[0,0,0,0],
						[0,0,2,0],
						[0,0,0,0],
						[2,2,2,2],
						[3,0,3,3],
						[2,2,2,2],
						[0,0,0,0],
						[2,2,2,3],
						[2,3,3,2],
						[0,0,0,3],
						[3,2,2,2],
						[2,2,2,2],
						[0,0,1,3],
						[0,3,3,0],
						[3,3,3,0],
						[2,2,2,2],
						[0,3,3,3],
						[1,0,2,1],
						[3,0,3,0],
						[2,2,2,2],
						[2,2,2,2],
						[2,0,3,2],
						[2,2,2,2] ];

var runs = ['runH1','runH2','runH3','runH4'];

var vtcFolder = dataRoot + "\\ANALYSIS\\VTC-data-SS6";
var sdmFolder = dataRoot + "\\ANALYSIS\\EffectBlock\\SDMs";
var outputFolder = dataRoot + "\\ANALYSIS\\EffectBlock\\Output_Javascript_5RegionNetwork_June2019";

// RETRIEVE VOI FILE
var docVMR = BrainVoyager.ActiveDocument;

var VOIFile = "F:\\DATA_VP_Hysteresis_TAL\\ANALYSIS\\ControlRunsPerCond\\VOI_Network5regions_6mm.voi";
var ok = docVMR.LoadVOIFile(VOIFile);
if(!ok) {
	BrainVoyager.PrintToLog("Could not open .VOI file");
	return;
}

var n_vois = docVMR.NrOfVOIs;

// Iterate on the ROIs
for (var r = 0; r < n_vois; r++) {

	// FILE I/O
	var voiName = docVMR.GetNameOfVOI(r);

	var idx_counts = [0, 0, 0, 0]; //index counter for Beta for PC_A, PC_P, CP_A, CP_P
	
	var beta_matrix = [[], [], [], []]; //Betas for PC_A, PC_P, CP_A, CP_P

	// Iterate on the subjects
	for (var s = 0; s < subs.length; s++) {

		var dataRootSubj = dataRoot + '\\' + subs[s] + '\\';
		
		// Iterate on the runs
		for (var i = 0; i < runs.length; i++) {

			// Link VTC
			var VTCfile = vtcFolder + '\\' + 'run-' + runs[i] + '-data\\' + subs[s] +'_'+ runs[i] +'_SCCAI_3DMCTS_LTR_THPGLMF2c_TAL_SD3DVSS6.00mm.vtc';
			docVMR.LinkVTC(VTCfile);

			// Load SDM
			docVMR.ClearDesignMatrix();
			docVMR.LoadSingleStudyGLMDesignMatrix(sdmFolder + "\\" +  subs[s] +  "_" + runs[i] + "_3DMC_SPK.sdm");
			var n_preds = docVMR.NrOfPredictorsInSingleStudyDM;

			// VOI-GLM
			docVMR.PrepareROIContrasts(n_preds); // param: number of predictors
			docVMR.AddROIContrast("Patt_Comp_2 vs Static", "-1 0 0 1 0 0 0 0");
			docVMR.AddROIContrast("Comp_Patt_2 vs Static", "-1 0 0 0 1 0 0 0");
			docVMR.AddROIContrast("Patt_Comp_3 vs Static", "-1 0 0 0 0 1 0 0");
			docVMR.AddROIContrast("Comp_Patt_3 vs Static", "-1 0 0 0 0 0 1 0");

			// param 1: VOI index (0-based)
			// param 2: time course normalization, 0 -> none, 1 -> percent change, 2 -> z, 3 -> z in baseline periods
			// param 3: serial correlation correction, 0 -> none, 1 -> with AR(1) model, 2 -> with AR(2) model  (OPTION AR(2) DOES NOT WORK)
			docVMR.ComputeSingleStudyGLMForVOI(r, 1, 0);

			// Get beta values for each predictor (WITHOUT correction for serial correlations!!!!!!!)
			var b_val = [];
			for(var b=0; b<n_preds; b++) {
				b_val[b] = docVMR.GetBetaValueOfROIGLM(b);
			}
			var c_beta = [b_val[3]-b_val[0] , b_val[4]-b_val[0] , b_val[5]-b_val[0] , b_val[6]-b_val[0]];

			// Get t and p values of contrast
			var c_t = [];
			var c_p = [];

			for(var ii=0; ii<docVMR.NrOfROIContrasts; ii++) {
				c_t[ii] = docVMR.GetTValueOfROIContrast(ii);
				c_p[ii] = docVMR.GetPValueOfROIContrast(ii);
			}

			// Write to matrix depending on run group

			// Patt_Comp condition
			switch(subs_group_pc[s][i]) {
				case 1: // Adaptation group
					beta_matrix[0][idx_counts[0]] = c_beta[0];
					idx_counts[0]+=1;
			        break;
				case 2: // Persistence group
					beta_matrix[1][idx_counts[1]] = c_beta[0];
					idx_counts[1]+=1;
					break;
				default:
					// Do nothing
			}
			// Comp_Patt condition
			switch(subs_group_cp[s][i]) {
				case 1: // Adaptation group
					beta_matrix[2][idx_counts[2]] = c_beta[1];
					idx_counts[2]+=1;
			        break;
				case 2: // Persistence group
					BrainVoyager.PrintToLog(idx_counts[3])
					beta_matrix[3][idx_counts[3]] = c_beta[1];
					idx_counts[3]+=1;
					break;
				default:
					// Do nothing
			}

		} // end run iteration

	} // end subject iteration

	// Export CSV
	exportToTXT(outputFolder + "\\Output_" + voiName + '.txt', beta_matrix)

} // end ROI iteration

function exportToTXT(filename, array) {

	var f1 = new QFile(filename);

	f1.open(new QIODevice.OpenMode(QIODevice.WriteOnly | QIODevice.Text));

	var ts1 = new QTextStream(f1);

	var dims = [array[0].length, array[1].length, array[2].length, array[3].length];

	var max_dim = Math.max.apply(null,dims);
	var max_dim_i = dims.indexOf(max_dim);

	var array_transpose = array[max_dim_i].map(function (_, c) { return array.map(function (r) { return r[c]; }); });

	for (var index = 0; index < max_dim; index++) {

		ts1.writeString(array_transpose[index].join('	') + "\n");
		
	}

	f1.close();
	
}
