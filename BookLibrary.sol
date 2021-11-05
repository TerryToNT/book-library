// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract BookLibrary is Ownable {
    
    event NewBook(string name, uint copies);

    struct Book {
        string name;
        uint copies;
    }
    
    Book[] public books;
 
    mapping (uint => address[]) public bookToBorrowers;
    //address of borrower mapped to mapping of bookId and boolean if book is borrowed from him at the moment
    mapping (address => mapping (uint => bool)) public borrowersBooks;
    
    modifier isValidBook(string memory _name) {
        bytes memory tempBookName = bytes(_name);
        require(tempBookName.length > 0, 'Invalid book name!');
        _;
    }
    
    function addNewBook(Book calldata book) public onlyOwner isValidBook(book.name) {
        books.push(Book(book.name, book.copies));
        emit NewBook(book.name, book.copies);
    }
    
    function addCopiesToBook(uint _bookId, uint _copiesNumber) public onlyOwner {
        books[_bookId].copies += _copiesNumber;
    }
    
    function editBookName(uint _bookId, string memory _newBookName) public onlyOwner isValidBook(_newBookName) {
        books[_bookId].name = _newBookName;
    }
    
    function showAvailableBooks() public view returns(Book[] memory) {
        //TODO return only available books
        return books;
    }
    
    function borrowBook(uint _bookId) public {
        require(books[_bookId].copies > 0, 'There is no more copies of this book.');
        require(!borrowersBooks[msg.sender][_bookId], 'You already borrowed this book.');

        borrowersBooks[msg.sender][_bookId] = true;
        books[_bookId].copies--;
        _addBorrowerToBookList(_bookId);
    }
    
    function returnBook(uint _bookId) public {
        require(borrowersBooks[msg.sender][_bookId], 'You have not borrow this book.');
        
        borrowersBooks[msg.sender][_bookId] = false;
        books[_bookId].copies++;
    }
    
    function showBookBorrowers(uint _bookId) public view returns(address[] memory) {
        return bookToBorrowers[_bookId];
    }
    
    function _addBorrowerToBookList(uint _bookId) internal {
        bool hasRecord = false;
        
        for(uint i = 0; i < bookToBorrowers[_bookId].length; i++) {
            if (bookToBorrowers[_bookId][i] == msg.sender) {
                hasRecord = true;
                break;
            }
        }
        
        if (!hasRecord) {
            bookToBorrowers[_bookId].push(address(msg.sender));
        }
    }
}
