%%
function exists = h5exists(filename, path)
    try
        info = h5info(filename, path);
        exists = ~isempty(info);
    catch
        exists = false;
    end
end

