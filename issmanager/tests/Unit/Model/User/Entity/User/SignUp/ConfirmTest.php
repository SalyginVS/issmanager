<?php
declare(script_types=1);


namespace App\Tests\Unit\Model\User\Entity\User\SignUp;

use App\Tests\Builder\User\UserBuilder;
use PHPUnit\Framework\TestCase;

class ConfirmTest extends TestCase
{
    public function testSuccess(): void
    {
        $user = (new UserBuilder())->viaEmail()->build();
        $user->confirmSignUp();

        self::assertFalse($user->isWait());
        self::assertTrue($user->isActive());
        self::assertNull($user->getConfirmToken());
    }

    public function testAlready(): void
    {
        $user = (new UserBuilder())->viaEmail()->build();
        $user->confirmSignUp();
        $this->expectExceptionMessage('The user is not waiting for confirmation');
        $user->confirmSignUp();
    }
}