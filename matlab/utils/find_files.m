function file_list = find_files(path, regex)
    % Returns files in directory matching regular expression
    %
    % Args:
    %  path: directory name
    %  regex: regular expression
    %
    % Returns:
    %  file_list: cell array of strings
    
    listing = dir(path);
    
    file_list = {};
    
    for i = 1:numel(listing)
       
        curr_listing = listing(i);
        
        % Skip directories
        if curr_listing.isdir == 1
            continue
        end
        
        % Skip files that do not match regular expression
        if isempty(regexpi(curr_listing.name, regex))
            continue
        end
        
        file_full_path = [curr_listing.folder '/' curr_listing.name];
        file_list = [file_list; file_full_path];
        
    end
    
    file_list = natsortfiles(file_list);

    if isempty(file_list)
        error(['No files found in path: ''%s'' matching '...
               'regular expression ''%s''.'], ...
               path, regex)
    end
    
end