% pop_runicansg() - Run an ICA decomposition of an EEG dataset in NSG.
%                   This is an example of how to implement a plugin using HPC
%                   resources at NSG through the EEGLAB plugin nsgportal
%                   (see pop_nsg)
% Usage: 
%             >> OUT_EEG = pop_runicansg(EEG);
%             >> OUT_EEG = pop_runicansg(EEG,'icatype','runica');
%
% Inputs:
%   EEG         - input EEG dataset or array of datasets
%
% Optional inputs:
%   'icatype'   - ['runica'|'binica'|'jader'| ICA algorithm 
%                 to use for the ICA decomposition. 
%
% Outputs:
%   OUT_EEG     - The input EEGLAB dataset with new fields icaweights, icasphere 
%                 and icachansind (channel indices). 
%
%  See also: 
%
% Authors: Ramon Martinez-Cancino  SCCN/INC/UCSD 2019

% Copyright (C) Ramon Martinez-Cancino, 2019
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function OUT_EEG = pop_runicansg(EEG, varargin)
OUT_EEG  = [];

%% Inputs block
if nargin < 1   
    help pop_runicansg;
    return;
end

allalgs   = { 'runica' 'binica' 'jader' }; 

if nargin < 2
    % GUI call
    cb_ica = 'close(gcbo);';        
    promptstr    = { { 'style' 'text'       'string' 'ICA algorithm to use (click to select)' } ...
                     { 'style' 'listbox'    'string' char(allalgs{:}) 'callback', cb_ica }};
    geometry = { [2 1.5]};  geomvert = 1.5;                        
    result       = inputgui( 'geometry', geometry, 'geomvert', geomvert, 'uilist', promptstr, ...
                             'helpcom', 'pophelp(''pop_runicansg'')', ...
                             'title', 'Run ICA decomposition in NSG -- pop_runicansg()');
    options = { 'icatype' allalgs{result{1}}};     
else
    % Command line call
    options = varargin;   
end

%% Create temporal folder and save data
nsg_info; % get information on where cto create the tempoal file
jobID = 'runicansg_tmpjob';

% Create a temporal folder
foldername = 'runicansgtmp';
tmpJobPath = fullfile(outputfolder,'runicansgtmp');
if exist(tmpJobPath,'dir'), rmdir(tmpJobPath,'s'); end
mkdir(tmpJobPath); 

% Save data in folder previously created. 
% Here change names to match the one onin the script you will run in NSG
newfilename = 'tempdatafile.set';
pop_saveset(EEG,'filename',newfilename , 'filepath',tmpJobPath);

%% Manage m-file to be executed in NSG
% Write m-file to be run in NSG.
% Options defined in plugin are written into the file

% File writing begin ---
fid = fopen( fullfile(tmpJobPath,'runicansg_job.m'), 'w');
fprintf(fid, 'eeglab;\n');
fprintf(fid, 'EEG = pop_loadset(''%s'');\n', newfilename);
fprintf(fid, 'EEG = pop_runica(EEG, ''%s'',''%s'');\n', options{1},options{2});
fprintf(fid, 'pop_saveset(EEG, ''filename'', ''%s'');\n',EEG.filename);
fclose(fid);
% File writing end ---

%% Submit job to NSG
jobstruct = pop_nsg('run',tmpJobPath,'filename', 'runicansg_job.m', 'jobid', jobID,'runtime', 0.5); 

% ---
% Alternatively, the script may end up here. In this case consider adding
% the job structure 'jobstruct' to the output of the function so the job
% can be tracked. Note that NSG jobs can be retreived either by the NSG job ID
% ,the NSG job structure or NSG job URL. (see pop_nsg help)

%% Activate recurse polling
% Job status is checked every 60 second. Once finished, the function exits
% returning the NSG job structure. This structure is used in the nex step
% to download the results.

jobstructout = nsg_recurspoll(jobstruct,'pollinterval', 60);

%% Download data
pop_nsg('output',jobstructout); 

%% Delete job (aleternatively)
pop_nsg('delete',jobstructout);

%% Open data in EEGLAB and return results
OUT_EEG = pop_loadset(EEG.filename,fullfile(outputfolder,['nsgresults_' jobID],foldername));

end