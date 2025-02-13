function [predYArr, modelMat, rmseArr, mind, mModelName] = lmm_main(testfile)

% main script for linear mixed model

% load(testfile, 'y','age','dise','group','loc','gen','id');

load('test.mat')
X = [y ageVec seroAgeVec groupVec locVec genderVec idVec];
varNames = {'y','age','dise','group','loc','gen','id'};

tbl = array2table(X);
% tbl{:,3} = NaN;
tbl.Properties.VariableNames = varNames;
tbl.group = nominal(tbl.group);
tbl.loc = nominal(tbl.loc);
tbl.gen = nominal(tbl.gen);
tbl.id = nominal(tbl.id);

% formula = 'y ~ age + (dise-1|group) + (age|id) + (age|loc) + (age|gen) +(age|group)';
% lme = fitlme(tbl,formula);

% % plot fitting against real value
% predY = fitted(lme);
% clf
% hold on
% for i=1:40
%     tmpinds = idVec==i;
%     plot(ageVec(tmpinds),predY(tmpinds),'b-')
%     plot(ageVec(tmpinds),y(tmpinds),'ro')
% end

% cross validation
nfold=10;
npoint = length(idVec);
[trn_inds, tst_inds] = genCVinds(npoint,nfold);

% all 32 models
formulaArr = {'y ~ 1 + (1|id)',...
    'y ~ age + (age|id)',...
    'y ~ dise + (1|id)',...
    'y ~ age + dise + (age|id)',...
    'y ~ loc + (1|id)',...
    'y ~ age + loc*age + (age|id)',...
    'y ~ dise + loc + (1|id)',...
    'y ~ age + dise + loc*age + (age|id)',...
    'y ~ gen + (1|id)',...
    'y ~ age + gen*age + (age|id)',...
    'y ~ dise + gen + (1|id)',...
    'y ~ age + dise + gen*age + (age|id)',...
    'y ~ loc + gen + (1|id)',...
    'y ~ age + loc*age + gen*age + (age|id)',...
    'y ~ dise + loc + gen + (1|id)',...
    'y ~ age + dise + loc*age + gen*age + (age|id)',...
    'y ~ group + (1|id)',...
    'y ~ age + group*age + (age|id)',...
    'y ~ dise + group + (1|id)',...
    'y ~ age + dise + group*age + (age|id)',...
    'y ~ loc + group + (1|id)',...
    'y ~ age + loc*age + group*age + (age|id)',...
    'y ~ dise + loc + group + (1|id)',...
    'y ~ age + dise + loc*age + group*age + (age|id)',...
    'y ~ gen + group + (1|id)',...
    'y ~ age + gen*age + group*age + (age|id)',...
    'y ~ dise + gen + group + (1|id)',...
    'y ~ age + dise + gen*age + group*age + (age|id)',...
    'y ~ loc + gen + group + (1|id)',...
    'y ~ age + loc*age + gen*age + group*age + (age|id)',...
    'y ~ dise + loc + gen + group + (1|id)',...
    'y ~ age + dise + loc*age + gen*age + group*age + (age|id)',...
    };

varNames = {'group','gen','loc','dise','age'};
varFlagArr = zeros(32,5);
modelNameArr = cell(32,1);
k = 1;
tmpVarFlag = zeros(1,5);
for i1 = 0:1
    tmpVarFlag(1)=i1;
    for i2 = 0:1
        tmpVarFlag(2)=i2;
        for i3 = 0:1
            tmpVarFlag(3)=i3;
            for i4 = 0:1
                tmpVarFlag(4)=i4;
                for i5 = 0:1
                    tmpVarFlag(5)=i5;
                    varFlagArr(k,:) = tmpVarFlag;
                    modelNameArr{k} = strjoin([varNames(tmpVarFlag>0) {'id'}],',');
                    k=k+1;
                end
            end
        end
    end
end

% formula = 'y ~ age + loc*age + gen*age + group*age + (age|id)';
% tmpmdl = fitlme(tbl,formula);
% [predY, modelArr, rmse] = lmm(tbl, formula, nfold, trn_inds, tst_inds);

nModel = 32;
predYArr = cell(nModel,1);
modelMat = cell(nModel,nfold);
rmseArr = cell(nModel,1);

for i = 1:nModel
    fprintf('\nmodel %d. \n',i);
    [predYArr{i}, modelMat(i,:), rmseArr{i}] = lmm(tbl, formulaArr{i}, nfold, trn_inds, tst_inds);
end

% choose the best model based on rmse
[mval, mind]=min(cell2mat(rmseArr));
mModelName = modelNameArr{mind};
fprintf('The best model is model %d: y~%s, rmse=%.3f.\n',mind, modelNameArr{mind}, mval);
