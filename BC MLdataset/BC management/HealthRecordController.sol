// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract DatasetFilesController is Auth {

    mapping (address => dataowner) private dataowners;
    mapping (address => platform) private platforms;
    mapping (address => researcher) private researchers;
    mapping (address => mapping (address => uint)) private researcherToDataowner;
    mapping (address => mapping (address => uint)) private researcherToPlatform;
    mapping (bytes32 => filesInfo) private hashToFile;
    mapping (address => mapping (bytes32 => uint)) private researcherToFile;

    //event
    event SignupResearcherEvent(address ra,uint timestamp);
    event SignupDataownerEvent(address do,uint timestamp);
    event SignupPlatformEvent(address agy,uint timestamp);
    event GrantAccessToDataownerEvent(address ra,address dataowner_id,uint timestamp);
    event GrantAccessToPlatformEvent(address ra,address platform_id,uint timestamp);
    event AddFileEvent(address ra,bytes32 _fileHash,uint timestamp);


    struct researcher {
        string phonenumber; 
        string name;
        uint8 age;
        address id;
        bytes32[] files;
        address[] dataowner_list; 
        address[] platform_list; 
        uint   researcher_create_time;
    }


    struct dataowner {
        string name;
        address id;
        address[] researcher_list; 
        uint   dataowner_create_time;
    }

   
    struct platform {
        string name;
        address id;
        address[] researcher_list; 
        uint   platform_create_time;
    }

  
    struct filesInfo {
        string file_name;
        string file_type;
        string file_secret;
        uint   file_create_time;
    }

    
    modifier checkResearcher(address id) {
        researcher memory p = researchers[id];
        require(p.id > address(0x0));
        _;
    }

    modifier checkDataowner(address id) {
        dataowner memory d = dataowners[id];
        require(d.id > address(0x0));
        _;
    }

   
    modifier checkPlatform(address id) {
        platform memory a = platforms[id];
        require(a.id > address(0x0));
        _;
    }

  
    modifier checkFile(bytes32 fileHashId) {
        bytes memory tempString = bytes(hashToFile[fileHashId].file_name);
        require(tempString.length > 0);
        _;
    }

 
    modifier checkFileAccess(string memory role, address id, bytes32 fileHashId, address ra) {
        uint pos;
        if(keccak256(abi.encodePacked(role)) == keccak256("dataowner")) {
            require(researcherToDataowner[ra][id] > 0);
            pos = researcherToFile[ra][fileHashId];
            require(pos > 0);
        }
        if(keccak256(abi.encodePacked(role)) == keccak256("platform")) {
            require(researcherToPlatform[ra][id] > 0);
            pos = researcherToFile[ra][fileHashId];
            require(pos > 0);
        }
        else if(keccak256(abi.encodePacked(role)) == keccak256("researcher")) {
            pos = researcherToFile[id][fileHashId];
            require(pos > 0);
        }
        _;
    }


    
    function signupResearcher(string memory _phonenumber, string memory _name, uint8 _age) public {
        researcher storage p = researchers[msg.sender];
        require(keccak256(abi.encodePacked(_name)) != keccak256(""));
        require((_age > 0) && (_age < 200));
        require(!(p.id > address(0x0)));

        researchers[msg.sender] = researcher({phonenumber:_phonenumber,name:_name,age:_age,id:msg.sender,files:new bytes32[](0),dataowner_list:new address[](0),platform_list:new address[](0),researcher_create_time:now});
        emit SignupResearcherEvent(msg.sender,now);
    }

 
    function signupDataowner(string memory _name) public {
        dataowner storage d = dataowners[msg.sender];
        require(keccak256(abi.encodePacked(_name)) != keccak256(""));
        require(!(d.id > address(0x0)));

        dataowners[msg.sender] = dataowner({name:_name,id:msg.sender,researcher_list:new address[](0),dataowner_create_time:now});
        emit SignupDataownerEvent(msg.sender,now);
    }

    function signupPlatform(string memory _name) public {
        platform storage d = platforms[msg.sender];
        require(keccak256(abi.encodePacked(_name)) != keccak256(""));
        require(!(d.id > address(0x0)));

        platforms[msg.sender] = platform({name:_name,id:msg.sender,researcher_list:new address[](0),platform_create_time:now});
        emit SignupPlatformEvent(msg.sender,now);
    }


    function grantAccessToDataowner(address dataowner_id) public checkResearcher(msg.sender) checkDataowner(dataowner_id) {
        researcher storage p = researchers[msg.sender];
        dataowner storage d = dataowners[dataowner_id];
        require(researcherToDataowner[msg.sender][dataowner_id] < 1);

        uint pos = p.dataowner_list.push(dataowner_id);
        researcherToDataowner[msg.sender][dataowner_id] = pos;
        d.researcher_list.push(msg.sender);
        emit GrantAccessToDataownerEvent(msg.sender,dataowner_id,now);
    }


    function addFile(address ra,string memory _file_name, string memory _file_type, bytes32 _fileHash, string memory _file_secret) public checkDataowner(msg.sender) checkResearcher(ra) {
        researcher storage p = researchers[ra];

        require(researcherToFile[ra][_fileHash] < 1);

        hashToFile[_fileHash] = filesInfo({file_name:_file_name, file_type:_file_type,file_secret:_file_secret,file_create_time:now});
        uint pos = p.files.push(_fileHash);
        researcherToFile[ra][_fileHash] = pos;
        emit AddFileEvent(msg.sender,_fileHash,now);
    }


    function getResearcherInfoForDataowner(address ra) public view checkResearcher(ra) checkDataowner(msg.sender) returns(string memory, uint8, address, bytes32[] memory){
        researcher memory p = researchers[ra];

        require(researcherToDataowner[ra][msg.sender] > 0);

        return (p.name, p.age, p.id, p.files);
    }

  
    function getResearcherInfo() public view checkResearcher(msg.sender) returns(string memory, uint8, bytes32[] memory , address[] memory) {
        researcher memory p = researchers[msg.sender];
        return (p.name, p.age, p.files, p.dataowner_list);
    }


    function getFileInfo(bytes32 fileHashId) private view checkFile(fileHashId) returns(filesInfo memory) {
        return hashToFile[fileHashId];
    }

 
    function getFileSecret(bytes32 fileHashId, string memory role, address id, address ra) public view checkFile(fileHashId) checkFileAccess(role, id, fileHashId, ra) returns(string memory) {
        filesInfo memory f = getFileInfo(fileHashId);
        return (f.file_secret);
    }


    function getFileInfoDataowner(address doc, address ra, bytes32 fileHashId) public view onlyOwner checkResearcher(ra) checkDataowner(doc) checkFileAccess("dataowner", doc, fileHashId, ra) returns(string memory, string memory,uint) {
        filesInfo memory f = getFileInfo(fileHashId);
        return (f.file_name, f.file_type,f.file_create_time);
    }


    function getFileInfoResearcher(address ra, bytes32 fileHashId) public view onlyOwner checkResearcher(ra) checkFileAccess("researcher", ra, fileHashId, ra)
    returns(string memory, string memory) {
        filesInfo memory f = getFileInfo(fileHashId);
        return (f.file_name, f.file_type);
    }


    function grantAccessToPlatform(address platform_id) public checkResearcher(msg.sender) checkPlatform(platform_id) {
        researcher storage p = researchers[msg.sender];
        platform storage a = platforms[platform_id];
        require(researcherToPlatform[msg.sender][platform_id] < 1);

        uint pos = p.platform_list.push(platform_id);
        researcherToPlatform[msg.sender][platform_id] = pos;
        a.researcher_list.push(msg.sender);
        emit GrantAccessToPlatformEvent(msg.sender,platform_id,now);
    }


    function getResearcherInfoForPlatform(address ra) public view checkResearcher(ra) checkPlatform(msg.sender) returns(string memory, uint8, address, bytes32[] memory){
        researcher memory p = researchers[ra];

        require(researcherToPlatform[ra][msg.sender] > 0);

        return (p.name, p.age, p.id, p.files);
    }


    function getFileInfoPlatform(address agy, address ra, bytes32 fileHashId) public view onlyOwner checkResearcher(ra) checkPlatform(agy) checkFileAccess("platform", agy, fileHashId, ra) returns(string memory, string memory,uint) {
        filesInfo memory f = getFileInfo(fileHashId);
        return (f.file_name, f.file_type,f.file_create_time);
    }

}
