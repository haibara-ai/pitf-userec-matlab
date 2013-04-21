function ret = FiltData(data,index_dim,filter)

ret = nan(size(data));
index = 1;

for i = 1:length(filter)
    index_data = data(data(:,index_dim) == filter(i),:);
    ret(index:index+size(index_data,1)-1,:) = index_data;
    index = index + size(index_data,1);
end
ret(isnan(ret(:,index_dim)),:) = [];
end