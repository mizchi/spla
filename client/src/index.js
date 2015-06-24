import subscriber from './room/subscriber';
import Room from './room/room';
import uuid from 'uuid';
import React from 'react'

let state = {
  username: "user:" + uuid(),
  x: ~~(Math.random() * 100),
  y: ~~(Math.random() * 100)
};
let stride = 5;

let $ = React.createElement;
let Board = React.createClass({
  getInitialState() {
    return {
      x: 0,
      y: 0
    }
  },
  render(){
    // return $('h1', {}, 'hello');
    return $('svg', {}, [
      $('circle', {rx: this.state.x, ry: this.state.y, r: 10})
    ]);
  }
});

window.addEventListener("load", () => {
  console.log('application loaded');
  let room = new Room('aaa', state.username);
  room.ready.then(obj => {
    // room.channel.push("new:msg", {user: 'a', body: 'body'})
    room.channel.push("update", state);
    subscriber(room.channel);
  });

  window.addEventListener("keydown", e => {
    if (e.keyCode === 40) {
      state.y += stride
    } else if (e.keyCode === 38) {
      state.y -= stride
    } else if (e.keyCode === 39) {
      state.x += stride
    } else if (e.keyCode === 37) {
      state.x -= stride
    }
    console.log(state);
    room.channel.push("update", state);
    render(state);
  });

  let app = React.render($(Board, {}), document.body);
  function render(state) {
    app.setState(state);
  }
});
