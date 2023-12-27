import './public-path';
import ready from '../mastodon/ready';

ready(() => {
  const image = document.querySelector('img');

  image.addEventListener('mouseenter', () => {
    image.src = '/oops.png';
  });

  image.addEventListener('mouseleave', () => {
    image.src = '/oops.gif';
  });
});
