% Assign a path to the .csv files that contain the participant data
csvfile = '/projects/sbagheri/for_combat_Dec7_2023.csv';

% Read contents of .csv file into a structure
sdat= tdfread(csvfile,',');

% Generate an array to store sex, diagnostic group info and scanner IDs 
% (1 - CMH, 2 -CMP, 3 - MRC, 4 - MRP, 5 -ZHH, 6 - ZHP)

for idx = 1:length(sdat.demo_sex)    
    % Assign scanner IDs
    if sdat.scanner(idx,1:3) == 'CMH'
        scanner(1,idx) = 1;
    elseif sdat.scanner(idx,1:3) == 'CMP'
        scanner(1,idx) = 2;
    elseif sdat.scanner(idx,1:3) == 'MRC'
        scanner(1,idx) = 3;
    elseif sdat.scanner(idx,1:3) == 'MRP'
        scanner(1,idx) = 4;
    elseif sdat.scanner(idx,1:3) == 'ZHH'
        scanner(1,idx) = 5;
    elseif sdat.scanner(idx,1:3) == 'ZHP'
        scanner(1,idx) = 6;
    end
    
    % Assign sex: 0 male and 1 female
    if sdat.demo_sex(idx,1:4) == 'male'
        sex(1,idx) = 0;
    else
        sex(1,idx) = 1;
    end
    
    % Assign diagnostic group: 0 ASD, 1 SSD, 2 TDC
    if sdat.diagnostic_group(idx,1:3) == 'ASD'
       group(1,idx) = 0;
    elseif sdat.diagnostic_group(idx,1:3) == 'SSD'
       group(1,idx) = 1;
    elseif sdat.diagnostic_group(idx,1:7) == 'Control'
       group(1,idx) = 2
    end
end

% Uncomment the following based on running slow 4 or slow 5 fALFF
%slow=4 % If using slow-4 fALFF
%slow=5	% If using slow-5 fALFF
basedir = '/projects/sbagheri/SPINS_and_SPASD/SPINS_SPASD_falff_standardized';

% Loop through and load the participants' functional data
for idx=1:length(scanner)
	% Extaract participant IDs from the record ID
	id =  strsplit(sdat.record_id(idx,1:14),'_');
	
	% Build file name for the SPASD data - all SPASD participant IDs are session 01 so that's how we name them
        fname = [basedir '/slow_' num2str(slow) '/SPASD-' id{2} id{3} '_ses-01_task-rest_desc-falffslow' num2str(slow) '.dscalar.nii' ]
        % Build file name for the SPINS data - some SPINS participants are session 01 and some are session 02 so we will find files and adjust names later accordingly
        if ~isfile(fname)
		fname = [basedir '/slow_' num2str(slow) '/SPN01-' id{2} id{3} '_ses-01_task-rest_run-1_desc-falffslow' num2str(slow) '.dscalar.nii' ]
		if ~isfile(fname)
			fname = [basedir '/slow_' num2str(slow) '/SPN01-' id{2} id{3} '_ses-02_task-rest_run-1_desc-falffslow' num2str(slow) '.dscalar.nii' ]
    	        end
        end

	% Read the CIFTI file
        d = ft_read_cifti(fname);
        % Store data in a matrix where rows represent participants, and columns define the vertices
        dat(idx,:) = d.dscalar; 
end


% Remove columns with NaN values
dat = dat(:, ~isnan(dat(1,:)));

% Transpose matrix for ComBat harmonization
dat_ord = dat.';

% Define model variables of Interest: sex, age, soc cog score and groups
mod = [sex.' sdat.er40_total sdat.tasit3_sar sdat.demo_age_study_entry group.'];

% Run ComBat to harmonize data across scanners
dat_harmonized = combat(dat_ord,scanner,mod,1);
dat_harmonized = dat_harmonized.';

clear dat;

% Output directory for harmonized data
outdir = '/projects/sbagheri/SPINS_and_SPASD/falff_norm_combatted_lowfd_Dec13_2023/slow5';

% Save harmonized data
    for idx=1:length(scanner)
    
    	% Extract participant IDs
        id =  strsplit(sdat.record_id(idx,1:14),'_');

	% Construct file names again for SPASD and SPINS
        fname = [basedir '/slow_' num2str(slow) '/SPASD-' id{2} id{3} '_ses-01_task-rest_desc-falffslow' num2str(slow) '.dscalar.nii' ]
        if ~isfile(fname)
            fname = [basedir '/slow_' num2str(slow) '/SPN01-' id{2} id{3} '_ses-01_task-rest_run-1_desc-falffslow' num2str(slow) '.dscalar.nii' ]
            if ~isfile(fname)
                fname = [basedir '/slow_' num2str(slow) '/SPN01-' id{2} id{3} '_ses-02_task-rest_run-1_desc-falffslow' num2str(slow) '.dscalar.nii' ]
            end
        end

	% Read the original CIFTI files
        d = ft_read_cifti(fname);
        % Write the harmonized data back to original file
        d.dscalar(~isnan(d.dscalar(:))) = dat_harmonized(idx,:);

	% Define output file name for the harmonized data, keeping in mind session numbers for SPINS participants
        if isequal (fname, [basedir '/slow_' num2str(slow) '/SPASD-' id{2} id{3} '_ses-01_task-rest_desc-falffslow' num2str(slow) '.dscalar.nii' ])
            outname = [outdir '/SPASD-' id{2} id{3} '_ses-01_task-rest_desc-falffslow' num2str(slow) 'ComBat' ]
        elseif isequal (fname, [basedir '/slow_' num2str(slow) '/SPN01-' id{2} id{3} '_ses-01_task-rest_run-1_desc-falffslow' num2str(slow) '.dscalar.nii' ])
            outname = [outdir '/SPN01-' id{2} id{3} '_ses-01_task-rest_run-1_desc-falffslow' num2str(slow) 'ComBat' ]
        elseif isequal (fname, [basedir '/slow_' num2str(slow) '/SPN01-' id{2} id{3} '_ses-02_task-rest_run-1_desc-falffslow' num2str(slow) '.dscalar.nii' ])
            outname = [outdir '/SPN01-' id{2} id{3} '_ses-02_task-rest_run-1_desc-falffslow' num2str(slow) 'ComBat' ]
        end
        
        % Write harmoonized data to new CIFTI files
        ft_write_cifti(outname,d,'parameter','dscalar')
    end
    
outname = [basedir ]

