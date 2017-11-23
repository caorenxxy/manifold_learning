function [trainSet,testSet,trainLabel,testLabel,classNo,faceNo]=LoadData(Database,trainNo)
%--------train set,test set,trainlable,testlable

eval(['load ' 'DataBase\' Database '.mat']);
%          DataBase     -----ѡ�����ݿ�����ʵ�飬����ѡ��Ϊ'ORL','Yale','YaleB' or 'PIE'
%          group        -----���ɵ������ǩ�������ѡȡ��ͬ����������ѵ�����ܹ���50��;
%          type         -----���ݼ��صķ�ʽ������������'Original','Scale','Normalize'.
%              'Original'    ----����ԭʼͼ��Ҷ�ֵ
%              'Scale'       ----���Ҷ�ֵӳ�䵽[0,1]��
%              'Normalize'   ----��ÿ���������й�һ��
%          Data_type    -----���ݵĹ��췽ʽ,Ĭ��Ϊ���ѡ��,�� Data_type = 1;
%               0           -----�����ǰ�����Сѡ��
%               1           -----�������������ѡ��
% fea=XX;
% gnd=YY;
[nSmp,nFea] = size(fea);
showData(32,32,fea);
if (~exist('type','var'))
   type = 'Scale';
end
switch lower(type)
    case 'scale'
        maxValue = max(max(fea));                                 %�������ֵ��������ֵӳ�䵽[0,1]��
        fea = fea/maxValue;
    case 'normalize'
        for i=1:nSmp
            fea(i,:) = fea(i,:) ./ max(1e-12,norm(fea(i,:)));     %��ֹ����0������������һ������
        end
    case 'original';
    otherwise;
        error('��ѡȡ��ȷ�����ݼ��ط�ʽ��');
end
switch lower(Database(1:findstr(Database,'_')-1))%%ORL_32x32���֣�Ѱ��ORL
%     lower(faceMat(1:findstr(faceMat,'_')-1))
    case 'orl'
        classNo=40;faceNo=10;
    case 'yale'
         classNo=15;faceNo=11;
    case 'ar'
        classNo=120;faceNo=14;
    case 'yaleb'
        classNo=38;faceNo=64;
    case 'pie'
        classNo=68;faceNo=170;
    case 'feret'
        classNo=200;faceNo=7;

%  classNo -----ѡ����������ݿ�������ORLΪ40��YaleΪ15��YaleBΪ38��PIEΪ68
%  faceNo-----��ѡ����������ݿ��ÿ��������.ORLΪ10,YaleΪ11,YaleBΪ64��PIEΪ170
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ѡ��ѵ�����Ͳ��Լ�
trainIndex=[];testIndex=[];
for i=1:classNo  %%%����ÿһ��������Ҫȥѵ�����Ͳ��Լ�
    r=rand(1,faceNo);%%%����1*faceNo�ľ���
    [index,p]=sort(r);%%%index���Ǵ�С˳�������
    trainIndex=[trainIndex p(1:trainNo)+(i-1)*faceNo];
    testIndex=[testIndex p(trainNo+1:faceNo)+(i-1)*faceNo];
end
trainSet=fea(trainIndex,:);
testSet=fea(testIndex,:);
trainLabel=gnd(trainIndex);
testLabel=gnd(testIndex);
end