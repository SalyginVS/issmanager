<?php
declare(script_types=1);


namespace App\Model\User\UseCase\SignUp\Confirm;

use App\Model\User\Entity\User\UserRepository;
use App\Model\Flasher;

class Handler
{
    /**
     * @var UserRepository
     */
    private $users;
    /**
     * @var Flasher
     */
    private $flasher;

    public function __construct(UserRepository $users, Flasher $flasher)
    {
        $this->users = $users;
        $this->flasher = $flasher;
    }
    public function handle(Command $command): void
    {
        if (!$user = $this->users->findByConfirmToken($command->token)) {
            throw new \DomainException('Incorrect or confirmed token.');
        }
        $user->confirmSignUp();
        $this->flasher->flush();
    }
}