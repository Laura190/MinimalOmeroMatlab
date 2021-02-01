%% OMERO with MATLAB - Minimal Example
% Laura Cooper 29/01/2021
% Version: R2020b
% Demonstrates how to use OMERO with MATLAB and some basic tools. Futher 
% guidance can be found at 
% docs.openmicroscopy.org/omero/latest/developers/Matlab.html and
% https://omero-guides.readthedocs.io/en/latest/matlab/docs/matlab.html
%%
% Set up
% 1. Download the MATLAB plugin from 
%    www.openmicroscopy.org/omero/downloads/
% 2. Unzip the folder
% 3. Connect to the VPN (instructions available here:
%    warwick.ac.uk/services/its/servicessupport/networkservices/vpn/)
% 3. Open MATLAB
% 4. Navigate to the plugin folder
%%
% Loads the OMERO.matlab toolbox - after this step you can navigate to
% another folder
servername='camdu.warwick.ac.uk';
client = loadOmero(servername);

% Log in to OMERO. Storing your password in a file is 
% dangerous. Enter your details in the command window, connect, and then
% clear it using clc.
username=USER;
password=PASS;
session = client.createSession(username, password);

% Alternatively update the ice.config file in the plugin folder and run
% [client,session]=loadOmero('ice.config')
% Or create an encrypted credentials file

% For long running task you will need to use a 'keep alive' function
client.enableKeepAlive(60); % Calls keep alive every 60 seconds

% This will return the ID of the group you are connected to. This should be
% 53 for the public group
eventContext = session.getAdminService().getEventContext();
groupId = eventContext.groupId;
fprintf('The group ID is %d\n', groupId)

% Call a dataset from OMERO
datasetID=13852;
% true also calls attached images
loadedDatasets=getDatasets(session, datasetID, true);
dataset=loadedDatasets(1);
% Return name of dataset
datasetName=dataset.getName().getValue();
% List all the images in the dataset with name and ID
datasetImages=getImages(session,'dataset',13852);
for i = 1 : length(datasetImages)
    image = datasetImages(i);
    fprintf('%s , %i\n', image.getName().getValue(), image.getId().getValue());
end

% Call image from OMERO
image = datasetImages(1);
% Call the Pixels object to get metadata about image size
pixels = image.getPrimaryPixels();
sizeX = pixels.getSizeX().getValue(); % The number of pixels along the X-axis.
sizeY = pixels.getSizeY().getValue(); % The number of pixels along the Y-axis.
sizeZ = pixels.getSizeZ().getValue(); % The number of z-sections.
sizeT = pixels.getSizeT().getValue(); % The number of timepoints.
sizeC = pixels.getSizeC().getValue(); % The number of channels.
fprintf('The image dimensions are [x,y,z,c,t]: [%d %d %d %d %d]\n', sizeX,sizeY,sizeZ,sizeC,sizeT)

% Read intensity data from a single plane
plane=getPlane(session,317751,0,0,0);
maxInt=max(max(plane));
imshow(plane, [0,maxInt])

%Read intensity data from a stack
stack = getStack(session, image, 0, 0);

%Close session with OMERO
client.closeSession();