// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract BookLibrary is Ownable {
    
    event NewBook(string name, uint copies, uint id);

    struct Book {
        string name;
        uint copies;
    }
    
    uint bookIdDigits = 12; //lenght of book id
    uint bookIdModulus = 10 ** bookIdDigits;
    
    uint[] public bookIds;
    
    //address of borrower mapped to mapping of bookId and boolean if book is borrowed from him at the moment
    mapping (address => mapping (uint => bool)) public borrowersBooks;
    //bookId to Book
    mapping (uint => Book) public books;
    //bookId to array of borrowers addresses
    mapping (uint => address[]) public bookToArrayOfBorrowers;
    //bookId to mapping of borrower address to boolean. Used to validate if the borrower is already added to the array of borrowers for specific book
    mapping (uint => mapping (address => bool)) public bookToBorrowers;
    
    modifier isValidBookName(string memory _name) {
        require(bytes(_name).length > 0, 'Invalid book name!');
        _;
    }
    
    modifier validateChoosenBook(uint _bookId) {
        require(books[_bookId].copies > 0, 'There is no more copies of this book.');
        require(!borrowersBooks[msg.sender][_bookId], 'You already borrowed this book.');
        _;
    }
    
    modifier isNotBorrowed(uint _bookId) {
        require(borrowersBooks[msg.sender][_bookId], 'You have not borrow this book.');
        _;
    }
    
    modifier bookIsAdded(uint _bookId) {
        require(bytes(books[_bookId].name).length == 0, 'This book is already added.');
        _;
    }
    
    function addNewBook(Book calldata book) public onlyOwner isValidBookName(book.name) {
        uint bookId = _generateBookId(book.name);
        _createBook(book.name, book.copies, bookId);
        emit NewBook(book.name, book.copies, bookId);
    }
    
    function addCopiesToBook(uint _bookId, uint _copiesNumber) public onlyOwner {
        books[_bookId].copies += _copiesNumber;
    }
    
   
    function showAvailableBooks() public view returns(uint[] memory) {
        //Returns array with all books ids
        return bookIds;
    }
    
    function borrowBook(uint _bookId) public validateChoosenBook(_bookId) {
        borrowersBooks[msg.sender][_bookId] = true;
        books[_bookId].copies--;
        _addBorrowerToBookList(_bookId);
    }
    
    function returnBook(uint _bookId) public isNotBorrowed(_bookId) {
        borrowersBooks[msg.sender][_bookId] = false;
        books[_bookId].copies++;
    }
    
    function showBookBorrowers(uint _bookId) public view returns(address[] memory) {
        return bookToArrayOfBorrowers[_bookId];
    }
    
    function getBookData(uint _bookId) public view returns(Book memory) {
        return books[_bookId];
    }
    
    function _addBorrowerToBookList(uint _bookId) internal {
        if (!bookToBorrowers[_bookId][msg.sender]) {
            bookToArrayOfBorrowers[_bookId].push(address(msg.sender));
            bookToBorrowers[_bookId][msg.sender] = true;
        }
    }
    
    function _generateBookId(string memory _bookName) private view returns (uint) {
        uint bookId = uint(keccak256(abi.encodePacked(_bookName)));
        return bookId % bookIdModulus;
    }
    
    function _createBook(string memory _name, uint _copies, uint _id) private bookIsAdded(_id) {
        books[_id] = Book(_name, _copies);
        bookIds.push(_id);
    }
}
