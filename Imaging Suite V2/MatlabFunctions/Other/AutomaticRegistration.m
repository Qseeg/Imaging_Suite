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

% Automatic registration of images



function AutomaticRegistration(

addpath('spm12');


%Image: '/Users/sashadionisio/Desktop/AQIP Work/Imaging Suite V2/abMRI.nii'


%Load volume information
% % % VolumeInformation = spm_vol('/Users/sashadionisio/Desktop/AQIP Work/Imaging Suite V2/abMRI.nii');
% % % Matrix = spm_get_space(   '/Users/sashadionisio/Desktop/AQIP Work/Imaging Suite V2/abMRI.nii' );
% % % A = spm_imatrix(Matrix)

auto_reorient('/Users/sashadionisio/Desktop/AQIP Work/Imaging Suite V2/abMRI.nii')


%Moves to mm position in image
% spm_orthviews('Reposition',[x,y,z])
spm_orthviews('Reposition',[0 0 0])


[VolumeStruct, VolumeData] = ExtractVolume('/Users/sashadionisio/Desktop/AQIP Work/Imaging Suite V2/abMRI.nii');
%Identify the orign;









InputImage = '/Users/sashadionisio/Desktop/AQIP Work/Imaging Suite V2/abMRI.nii';
%Read data
InputVolume = spm_vol(InputImage);
if isempty(InputVolume), error('no input images specified.'), end
OutputVolume = InputVolume;


matlabbatch{1}.spm.util.imcalc.input = {'/Users/sashadionisio/Desktop/AQIP Work/Imaging Suite V2/abMRI.nii,1'};
matlabbatch{1}.spm.util.imcalc.output = 'output';
matlabbatch{1}.spm.util.imcalc.outdir = {'/Users/sashadionisio/Desktop/AQIP Work/Imaging Suite V2'};
matlabbatch{1}.spm.util.imcalc.expression = 'i1';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;



%Vo = spm_imcalc(Vi,Vo,f,flags,varargin);



%Uneccesary 
Vchk   = spm_cat_struct(OutputVolume,InputVolume);
refstr = 'output';
 %Error checking
[sts, str] = spm_check_orientations(Vchk, false);
if ~sts
    for i=1:size(str,1)
        fprintf('Warning: %s - using %s image.\n',strtrim(str(i,:)),refstr);
    end
end

%Variables
interp  = 0;
mask    = 0;
dmtx    = 0;
dtype   = spm_type('int16');
descrip = 'spm - algebra';



%-Computation
%==========================================================================
NumberOfImages = numel(InputVolume);
RawData = zeros(OutputVolume.dim(1:3));

%-Loop over planes computing result Y
%--------------------------------------------------------------------------
for Planes = 1:OutputVolume.dim(3)
    B = spm_matrix([0 0 -Planes 0 0 0 1 1 1]);

    for i = 1:NumberOfImages
        M = inv(B * inv(OutputVolume.mat) * InputVolume(i).mat);
        DataSlice = spm_slice_vol(InputVolume, M, OutputVolume.dim(1:2), [0,NaN]);
        
    end
    
    RawData(:,:,Planes) = reshape(DataSlice,OutputVolume.dim(1:2));

end
