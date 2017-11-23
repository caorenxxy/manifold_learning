function M=constructM(data,options)
%M=W+W'-W*W',����W��NPE�е�Ȩֵ����
%     Input:
%          data         ----ѵ����������ÿ�б�ʾһ������;
%          options      ----MATLAB�еĽṹ��,���Ĳ�������
%              'Mode'       ----�����Ǽල��ʽ'KNN'�ͼල��ʽ'Supervised',Ĭ��Ϊ'KNN'
%              'gnd'        ----ѵ��������������ǩ������ModeΪ'Supervised'�£��ұ����ṩ
%              'k'          ----����ModeΪ'KNN'�£�ѡȡ�Ľ��ڸ�����Ĭ��Ϊ5,�����������ܸ���
%     Output:
%          M            ----Ȩֵ����M��M_ijΪx_i�����Լ���Ϊ�Ľ���x_j�����ع�����С���˽�
%     Example:
%          DataBase='Yale';train_num=6;group=1;
%          [face_train,face_test,gnd_train,gnd_test]=loadData(DataBase,train_num,group,'Scale');
%          options=[];options.Mode='KNN';options.k=6;
%          W=constructW(face_train,options);
%     Written By ̷���������ݴ�ѧ�������ѧ�뼼��ѧԺ, tyq0502@gmail.com    
%     2011/7/21
if (~exist('options','var'))
   options = [];
end
if (~isfield(options,'Mode'))
    options.Mode='KNN';
end
[nSmp, nFea] = size(data);
%ֱ�Ӳ���EuDist2����������data*data'���ܻ�����ά�ȹ�������ڴ����
%��ά��̫�󣬲�ȡ�ֿ�ķ���
maxM = 62500000; 
BlockSize = floor(maxM/(nSmp*5));
tol=1e-12;
switch options.Mode
    case 'KNN'
        if (~isfield(options,'k'))
            options.k=5;
        end
        if (options.k>nSmp||options.k==1)
            error('������kδ��ȷ���ã�ӦС�����������Ҵ���1��');
        end
        if nSmp<BlockSize
            Dist=EuDist2(data);
            W=[];
            W=sparse(W);
            for i=1:nSmp
                max_temp=max(Dist(i,:));
                Dist(i,i)=max_temp+1;      %��x_i��ȥ
                for j=1:options.k-1        %���ڽ���Kͨ��ԶС��nSmp������sort����������find��������
                    idx=find(Dist(i,:)==min(Dist(i,:)));         %�ҵ���ǰ��Сֵ
                    neighborhood(j)=idx(1);
                    Dist(i,idx(1))=max_temp+1+Dist(i,idx(1));    %����Сֵ����
                end
                %ע�����������С���˽�ķ�����ʱҲ���Ǻܶ������ղ̵���NPE��д��д�ģ�ϣ�������ܰ���Ū���
                z=data(neighborhood,:)-repmat(data(i,:),options.k-1,1);
                C = z*z';
                C = C + eye(size(C))*tol*trace(C);                   % regularlization
                tW = C\ones(length(neighborhood),1);                           % solve Cw=1
                tW = tW/sum(tW);                  % enforce sum(w)=1
                W(neighborhood,i)=tW;
            end 
            clear Dist;
        else   %nSmp̫�󣬲�ȡ�ֿ�ķ���
            W=[];
            W=sparse(W);
            for i=1:ceil(nSmp/BlockSize)
                if i==ceil(nSmp/BlockSize)   %��������һ�飬�п���û��BlockSize��С
                    smpIdx = (i-1)*BlockSize+1:nSmp;
                else
                    smpIdx = (i-1)*BlockSize+1:i*BlockSize;
                end
                dist=EuDist2(data,data(smpIdx,:));
                for j=1:size(dist,1)
                    max_temp=max(dist(j,:));
                    dist(j,j)=max_temp+1;
                    for ii=1:options.k-1
                        idx=find(dist(j,:)==min(dist(j,:)));
                        neighborhood(ii)=idx(1);
                        dist(j,idx(1))=max_temp+1+dist(j,idx(1));
                    end
                    z=data(neighborhood,:)-repmat(data((i-1)*BlockSize+j,:),options.k-1,1);
                    C = z*z';
                    C = C + eye(size(C))*tol*trace(C);                   % regularlization
                    tW = C\ones(length(neighborhood),1);                           % solve Cw=1
                    tW = tW/sum(tW);                  % enforce sum(w)=1
                    W(neighborhood,data((i-1)*BlockSize+j))=tW;
                end
            end
            clear dist;
        end
    case 'Supervised'
        W=[];
        W=sparse(W);
        if (~isfield(options,'gnd'))
            error('�����ṩѵ����������ǩ��Ϣ��');
        end
        classLabel=unique(options.gnd);
        nClass=length(classLabel);
        for i=1:nSmp
            idx=find(options.gnd==options.gnd(i));
            idx(find(idx==i)) = [];
            z = data(idx,:)-repmat(data(i,:),length(idx),1);
            C = z*z';
            C = C + eye(size(C))*tol*trace(C);
            tW = C\ones(length(idx),1);
            tW = tW/sum(tW);
            W(idx,i) = tW;
        end
    otherwise
        error('options.Modeδ��ȷ����!');
end
M=W+W'-W*W';

%PS:  constructM������Ҫ�Ĳ�����options.k��kֵ�Ĳ�ͬ������Ӱ��Ƚϴ󣬸��ݱ���
%     ��ʵ�龭�飬����С��ģ���ݿ⣬kһ��ѡֵΪÿ��ѵ�������ĸ������������Yale
%     ��ÿ�����ѡ��6����������ѵ������ôk����Ϊ6��ʶ�����ܱȽϺá�������ڴ��
%     ģ���ݿ⣬�������NN��������kѡ��Ϊ2�ȽϺ��ʡ����������С���˽�ķ�������
%     ���൱�����Ͳ��о��ˣ����ܱ�����Ǳ��˱��Ƶ�רҵ����Ū��Щ��--��Ϣ������
%     ѧ��ϣ����ר���ܸ�������ע��

%    Reference:
%        X.F. He, D. Cai, S.C. Yan, H.J. Zhang. Neighborhood preserving 
%        embedding [C]. IEEE International Conference on Computer Vision, 
%        2005, 2: 1208-1213.