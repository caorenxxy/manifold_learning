function [eigvector, eigvalue, meanData, elapse] = PCA_T(data, options)
%���ɷַ���(Principal Component Analysis, PCA)
%     Input:
%          data         ----ѵ����������ÿ�б�ʾһ������;
%          options      ----MATLAB�еĽṹ��,���ɷֱ�����ά��
%              'PCARatio'   ----���������ɷ���ռ������Ĭ��Ϊ1.
%                               ��Ϊ(0,1]ʱ����ʾ����������ֵռԭʼ����ֵ�ı���
%                               ������1ʱ����ʾ������ά������󲻳���ԭʼ����ֵά��
%     Output:
%          eigvector    ----��������;
%          eigvalue     ----����ֵ
%          elapse       ----PCAѵ���ķ�ʱ��;
%     Example:
%          DataBase='Yale';train_num=6;group=1;
%          [face_train,face_test,gnd_train,gnd_test]=loadData(DataBase,train_num,group,'Scale');
%          options=[];options.PCARatio=0.9;
%          [eigvector, eigvalue]=PCA(face_train,options);
%     Written By ̷���������ݴ�ѧ�������ѧ�뼼��ѧԺ, tyq0502@gmail.com    
%     2011/7/21
time_temp=cputime;
[nSmp,nFea] = size(data);
if (~exist('options','var'))
   options = [];
end
if (~isfield(options,'PCARatio'))
    options.PCARatio=1;
end

ReducedDim=nFea;
if options.PCARatio>1
    ReducedDim = options.PCARatio;
end
meanData = mean(data);
data = data - repmat(meanData,nSmp,1);
if nFea/nSmp > 1.0713
    %%% ������ͼ���ά��������������ʱ������ȡdata*data'�������������ٽ���ת��data'*data����������
    ddata = data*data';
    dimMatrix = size(ddata,2);
    if dimMatrix > 1000 && ReducedDim < dimMatrix/10
        %%% ��Э�������ά�������ұ��������ɷ���������ά��������MATLAB�е�eigs���ٽ��������ֽ�
        option = struct('disp',0);
        [eigvector, eigvalue] = eigs(ddata,ReducedDim,'la',option);
        eigvalue = diag(eigvalue);
    else
        [eigvector, eigvalue] = eig(ddata);
        eigvalue = diag(eigvalue);
        [junk, index] = sort(-eigvalue);         %eig�ֽ��С�������У�����תΪ�Ӵ�С����
        eigvalue = eigvalue(index);
        eigvector = eigvector(:, index);
    end
    clear ddata;
    eigvector = data'*eigvector;   %ת����data'*data����������
    eigvector = eigvector*diag(1./(sum(eigvector.^2).^0.5));   %�������������й�һ��
else
    %%% ֱ����ȡdata'*data����������
    ddata = data'*data;
    ddata = max(ddata, ddata');
    dimMatrix = size(ddata,2);
    if dimMatrix > 1000 && ReducedDim < dimMatrix/10
        %%% ��Э�������ά�������ұ��������ɷ���������ά��������MATLAB�е�eigs���ٽ��������ֽ�
        option = struct('disp',0);
        [eigvector, eigvalue] = eigs(ddata,ReducedDim,'la',option);
        eigvalue = diag(eigvalue);
    else
        [eigvector, eigvalue] = eig(ddata);
        eigvalue = diag(eigvalue);
        [junk, index] = sort(-eigvalue);
        eigvalue = eigvalue(index);
        eigvector = eigvector(:, index);
    end
    clear ddata;
    eigvector = eigvector*diag(1./(sum(eigvector.^2).^0.5)); 
end

if options.PCARatio>1
    ReducedDim = options.PCARatio;
    if ReducedDim < length(eigvalue)
        eigvalue = eigvalue(1:ReducedDim);
        eigvector = eigvector(:, 1:ReducedDim);
    end
else
    eigIdx = find(eigvalue < 1e-10);
    eigvalue (eigIdx) = [];
    eigvector(:,eigIdx) = [];
    sumEig = sum(eigvalue);
    sumEig = sumEig*options.PCARatio;
    sumNow = 0;
    for idx = 1:length(eigvalue)
        sumNow = sumNow + eigvalue(idx);
        if sumNow >= sumEig
            break;
        end
    end
    eigvector = eigvector(:,1:idx);
    eigvalue=eigvalue(1:idx);
end 
elapse=cputime-time_temp;

%PS:  ����ʶ�������˫����֮һ����Ҫָ������PCA���Ȳ�������������ʶ������ģ���
%     Ϊʲô��ô������������ʶ��������֮�󣬿�����һ�������磬������������һ����
%     �֣��̹ţ���Ц����PCA�������꣬�Լ�Ҳ����������ܣ�ָ�����㣺��һ���Ǹ���
%     data*data'������data'*data��������������һ��Ҫ���ע�⣬���ھ����Ե�����
%     ����ά��Զ������������������ʹ�������˽���������������ԭʼ��ʽ�����ض����
%     �£�������������������ά��ʱ�Ͳ���Ҫ�������ˣ�ֱ����data'*data�������ֽ⣻
%     �ڶ�����ֵ�������ںܶ�PCA�����У�������඼û�м�ȥ��ֵ��������Ϊ�󲿷����
%     ���඼����ŷ�Ͼ���Ϊ��׼�����Լ�����ȥ��ֵ������û��Ӱ�죬ͬѧ�ǿ����Լ���
%     ��һ�£�������Ҫע�⣬�������PCA����ʱ��ѵ�����������ȥ��ֵ�Ժ���ͶӰ��
%     ��������ҲӦ����Ӧ�ļ�ȥ��ֵ��ͶӰ�����һ��ʼ��ѵ��������û�м�ȥ��ֵ�ͽ�
%     ��ͶӰ����ô��������Ҳ����Ҫ��ȥ��ֵ��

%    Reference:
%        M.A. Turk, A.P. Pentland. Eigenface for recognition [J]. Cognitive 
%        Neuroscience, 1991, 3(1): 71-86.