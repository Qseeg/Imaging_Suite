% Copyright 2020 QIMR Berghofer Medical Research Institute
% Author: Matthew Woolfe
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

%Input: p is the full filepath to the image
%Output: nothing -> the inputfile is reorientated and overwrtten.

function auto_reorient(p)

if(~exist(p,'file'))
    fprintf('File not found for automatic reorientation\n')
    return;
end

%Identify the file
[Path,~,~] = fileparts(p);

%Load Template MRI
spmDir=which('spm');
spmDir=spmDir(1:end-5);
tmpl=[spmDir 'canonical/avg152T1.nii'];
TemplateVolume=spm_vol(tmpl);
flags.regtype='rigid';

%Load File for reorientation
% % p=spm_select(inf,'image'); %Original Code
% We know the format (filepath,number);
p = strcat(p,',1'); %1 to indicate the position in SPM's volume structure
f=strtrim(p);

% Make a smoothed version of the input volume to make it quick and better
spm_smooth(f,fullfile(Path,'Smoothed.nii'),[12 12 12]);

%Load the volume information for the smoothed version
SmoothedVolume=spm_vol(fullfile(Path,'Smoothed.nii'));
[M,~] = spm_affreg(TemplateVolume,SmoothedVolume,flags);
M3=M(1:3,1:3);
[u, ~, v]=svd(M3);
M3=u*v';
M(1:3,1:3)=M3;

%Create Nifti structure with updated origin
N=nifti(f);
N.mat=M*N.mat;

%Save the data
create(N);

%Remove the smoothed version
if(exist(fullfile(Path,'Smoothed.nii'),'file'))
    delete(fullfile(Path,'Smoothed.nii'));
end

end
