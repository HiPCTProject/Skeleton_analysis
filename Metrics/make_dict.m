%%%
function dict= make_dict(test_feat)
     
str1 = '%f' ;%This is character vector, NOT a string
str2 = '%u';
n = test_feat{4};
if  contains(test_feat{3},'float')
 dict=strcat(repmat(str1,[1 n]),'\n');

elseif  contains(test_feat{3},'int')
    dict=strcat(repmat(str2,[1 n]),'\n');

end


end