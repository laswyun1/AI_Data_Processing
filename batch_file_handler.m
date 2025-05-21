clear; clc; close all;

%% FILE LOADING
% 현재 폴더 내의 모든 항목(파일+폴더) 정보
folderList = dir;

% . 혹은 .. 이 아닌, 실제 '폴더' 들만 추려냄
isRealFolder = [folderList.isdir] & ~ismember({folderList.name}, {'.','..'});
subFolders = folderList(isRealFolder);

% 하위 폴더별로 순회
for iF = 1:length(subFolders)
    subFolderName = subFolders(iF).name; 
    fprintf('----- 현재 폴더: %s -----\n', subFolderName);
    
    % 이 폴더 내의 모든 *.h5 파일 불러오기
    h5files = dir(fullfile(subFolderName, '*.h5'));
    
    for iFile = 1:length(h5files)
        h5Name = h5files(iFile).name;
        fullh5Path = fullfile(subFolderName, h5Name);
        
        fprintf('  -> 파일 처리: %s\n', fullh5Path);
        
        crop_with_label(fullh5Path);
        
        fprintf('     처리 완료.\n\n');
    end
end

fprintf('=== 전체 처리 완료 ===\n');