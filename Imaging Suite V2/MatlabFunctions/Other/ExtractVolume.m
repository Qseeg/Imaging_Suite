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

% Extract Volume Data
function [VolumeStruct, VolumeData] = ExtractVolume(InputAddress)


%Read data
InputVolume = spm_vol(InputAddress);
if isempty(InputVolume), error('no input images specified.'), end
VolumeStruct = InputVolume;


%Uneccesary 
Vchk   = spm_cat_struct(VolumeStruct,InputVolume);
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
VolumeData = zeros(VolumeStruct.dim(1:3));

%-Loop over planes computing result Y
%--------------------------------------------------------------------------
for Planes = 1:VolumeStruct.dim(3)
    B = spm_matrix([0 0 -Planes 0 0 0 1 1 1]);

    for i = 1:NumberOfImages
        M = inv(B * inv(VolumeStruct.mat) * InputVolume(i).mat);
        DataSlice = spm_slice_vol(InputVolume, M, VolumeStruct.dim(1:2), [0,NaN]);
        
    end
    
    VolumeData(:,:,Planes) = reshape(DataSlice,VolumeStruct.dim(1:2));

end
